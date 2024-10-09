//
//  AsyncProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import OSLog

// 실제 네트워크 요청을 처리하는 클래스

import OSLog  // LogMacro가 사용 불가능한 경우 (더 낮은 버전)

@available(iOS 12.0, macOS 10.15, *)
public class AsyncProvider<T: TargetType> {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func requestAsync<D: Codable & Sendable>(
        _ target: T,
        decodeTo type: D.Type
    ) async throws -> D {
        let request = URLRequestBuilder.buildRequest(from: target)
        // iOS 15.0 이상, macOS 12.0 이상에서 async/await 사용
        let result: Result<(Data, URLResponse), Error> = await session.dataResult(for: request)
        switch result {
        case .success(let (data, response)):
            guard let httpResponse = response as? HTTPURLResponse else {
                Log.error("No HTTP response received")
                throw DataError.noData
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                if let decodedData = try? data.decoded(as: D.self) {
                    Log.network("Request succeeded with data: \(httpResponse)")
                    return decodedData
                } else {
                    Log.error("Decoding failed for data with status code \(httpResponse.statusCode)")
                    throw DataError.noData
                }
            case 400:
                Log.error("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
                throw DataError.customError("Bad Request (400)")
            case 404:
                Log.error("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
                throw DataError.customError("Not Found (404)")
            default:
                Log.error("Unhandled status code: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
                throw DataError.unhandledStatusCode(httpResponse.statusCode)
            }
        case .failure(let error):
            Log.error("Request failed with error: \(error.localizedDescription)")
            throw error
        }
    }
}


@available(iOS 9.0, macOS 9.0, *)
public class AsyncProviders<T: TargetType> {
    // macOS 12.0 미만 및 iOS 15.0 미만에서 사용할 completion handler 기반의 비동기 요청 처리
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    @available(iOS 9.0, macOS 9.0, *)
    public func requestAsync<D: Codable>(
        _ target: T,
        decodeTo type: D.Type,
        completion: @Sendable @escaping (Result<D, Error>) -> Void
    ) {
        let request = URLRequestBuilder.buildRequest(from: target)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                Log.error("Request failed with error: \(error.localizedDescription)")
                completion(.failure(error))  // 에러 발생 시 처리
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                Log.error("No HTTP response or data received")
                completion(.failure(DataError.noData))  // 데이터가 없을 때 처리
                return
            }

            do {
                switch httpResponse.statusCode {
                case 200...299:
                    let decoded = try data.decoded(as: D.self)
                    Log.network("Request succeeded with data: \(httpResponse)")
                    completion(.success(decoded))  // 성공 시 처리
                case 400:
                    Log.error("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
                    completion(.failure(DataError.customError("Bad Request (400)")))
                case 404:
                    Log.error("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
                    completion(.failure(DataError.customError("Not Found (404)")))
                default:
                    Log.error("Unhandled status code: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
                    completion(.failure(DataError.unhandledStatusCode(httpResponse.statusCode)))
                }
            } catch {
                Log.error("Decoding failed with error: \(error.localizedDescription)")
                completion(.failure(error))  // 디코딩 실패 시 처리
            }
        }
        task.resume()
    }
}
