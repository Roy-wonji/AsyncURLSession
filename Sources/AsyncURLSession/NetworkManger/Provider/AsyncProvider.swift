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
    private let maxRetryCount = 3
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func requestAsync<D: Decodable & Sendable>(
        _ target: T,
        decodeTo type: D.Type
    ) async throws -> D {
        let request = URLRequestBuilder.buildRequest(from: target)
        return try await executeWithRetry(request: request, decodeTo: type, retryCount: 0)
    }
    
    private func executeWithRetry<D: Decodable & Sendable>(
        request: URLRequest,
        decodeTo type: D.Type,
        retryCount: Int
    ) async throws -> D {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Log.error("No HTTP response received")
            throw DataError.noData
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try data.decoded(as: D.self)
            
        case 400:
            Log.error("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
            throw DataError.customError("Bad Request (400)")
            
        case 404:
            Log.error("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
            throw DataError.customError("Not Found (404)")
            
        case 500:
            Log.error("Internal Server Error (500), attempting to decode response (Retry Count: \(retryCount + 1))")
            
            if retryCount < maxRetryCount {
                do {
                    return try data.decodeData(as: D.self, forStatusCode: httpResponse.statusCode)
                } catch {
                    Log.error("Decoding failed for 500 error response, retrying... (Retry Count: \(retryCount + 1))")
                    return try await executeWithRetry(request: request, decodeTo: type, retryCount: retryCount + 1)
                }
            } else {
                Log.error("Failed after 3 retries for 500 error response")
                throw DataError.unhandledStatusCode(httpResponse.statusCode)
            }
            
        default:
            Log.error("Unhandled status code: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
            throw DataError.unhandledStatusCode(httpResponse.statusCode)
        }
    }
}

@available(macOS 10.15, *)
extension AsyncProvider: @unchecked Sendable {}


@available(iOS 9.0, macOS 9.0, *)
public class AsyncProviders<T: TargetType> {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    @available(iOS 9.0, macOS 9.0, *)
    public func requestAsync<D: Decodable & Sendable>(
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
                    let decodedData = try self.decodeData(data, as: D.self, forStatusCode: httpResponse.statusCode)
                    Log.network("Request succeeded with data: \(decodedData)")
                    completion(.success(decodedData))  // 성공 시 처리
                case 400:
                    Log.error("Bad Request (400) for URL: \(request.url?.absoluteString ?? "No URL")")
                    completion(.failure(DataError.customError("Bad Request (400)")))
                case 404:
                    Log.error("Not Found (404) for URL: \(request.url?.absoluteString ?? "No URL")")
                    completion(.failure(DataError.customError("Not Found (404)")))
                case 500:
                    Log.error("Internal Server Error (500), attempting to decode response")
                    // 500 상태 코드여도 디코딩을 시도한다
                    let decodedData = try self.decodeData(data, as: D.self, forStatusCode: httpResponse.statusCode)
                    Log.network("Request succeeded despite 500 error, data: \(decodedData)")
                    completion(.success(decodedData))  // 성공 시 처리
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

    private func decodeData<D: Decodable>(_ data: Data, as type: D.Type, forStatusCode statusCode: Int) throws -> D {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(D.self, from: data)
        } catch {
            Log.error("Failed to decode response with status code: \(statusCode)")
            throw DataError.noData
        }
    }
}

@available(macOS 10.15, *)
extension AsyncProviders: @unchecked Sendable {}
