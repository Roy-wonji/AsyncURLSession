//
//  AsyncProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import LogMacro

// 실제 네트워크 요청을 처리하는 클래스
@available(iOS 9.0, macOS 10.15, *)
class NetworkProvider<T: TargetType> {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func requestAsync<D: Decodable & Sendable>(
        _ target: T,
        decodeTo type: D.Type
    ) async throws -> D {
        let request = URLRequestBuilder.buildRequest(from: target)
        if #available(iOS 12.0, macOS 12.0, *) {
            let result: Result<(Data, URLResponse), Error> = await session.dataResult(for: request)
            switch result {
            case .success(let (data, response)):
                guard let httpResponse = response as? HTTPURLResponse else {
                    #logError("No HTTP response received")
                    throw DataError.noData
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let decodedData = try? JSONDecoder().decode(D.self, from: data) {
                        #logNetwork("Request succeeded with data: \(httpResponse)")
                        return decodedData
                    } else {
                        #logError("Decoding failed for data with status code \(httpResponse.statusCode)")
                        throw DataError.noData
                    }
                case 400:
                    #logError("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
                    throw DataError.customError("Bad Request (400)")
                case 404:
                    #logError("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
                    throw DataError.customError("Not Found (404)")
                default:
                    #logError("Unhandled status code: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
                    throw DataError.unhandledStatusCode(httpResponse.statusCode)
                }
            case .failure(let error):
                #logError("Request failed with error: \(error.localizedDescription)")
                throw error
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        #logError("Request failed with error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                        #logError("No HTTP response or data received")
                        continuation.resume(throwing: DataError.noData)
                        return
                    }
                    do {
                        switch httpResponse.statusCode {
                        case 200...299:
                            let decoded = try JSONDecoder().decode(D.self, from: data)
                            #logNetwork("Request succeeded with data: \(httpResponse)")
                            continuation.resume(returning: decoded)
                        case 400:
                            #logError("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
                            continuation.resume(throwing: DataError.customError("Bad Request (400)"))
                        case 404:
                            #logError("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
                            continuation.resume(throwing: DataError.customError("Not Found (404)"))
                        default:
                            #logError("Unhandled status code: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
                            continuation.resume(throwing: DataError.unhandledStatusCode(httpResponse.statusCode))
                        }
                    } catch {
                        #logError("Decoding failed with error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        }
    }
}
