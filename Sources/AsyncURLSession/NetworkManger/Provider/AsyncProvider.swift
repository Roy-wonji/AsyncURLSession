//
//  AsyncProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import LogMacro

@available(iOS 13.0.0, *)
public class AsyncProvider<T: TargetType> {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func requestAsync<D: Decodable & Sendable>(
        _ target: T,
        decodeTo type: D.Type
    ) async throws -> D? {
        let request = URLRequestBuilder.buildRequest(from: target)
        let result: Result<(Data, URLResponse), Error> = await session.dataResult(for: request)
        // Result 타입으로 성공과 실패를 처리
        switch result {
        case .success(let (data, response)):
            guard let httpResponse = response as? HTTPURLResponse else {
                #logError("No HTTP response received")
                throw DataError.noData
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                if let decodedData = try? data.decoded(as: D.self) {
                    #logNetwork("Request succeeded data \(httpResponse)")
                    return decodedData
                } else {
                    #logError("Decoding failed for data with status code \(httpResponse.statusCode)")
                    return nil
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
            // 에러 발생 시 로그 출력 및 에러 throw
            #logError("Request failed with error: \(error.localizedDescription)")
            throw error
        }
    }
}
