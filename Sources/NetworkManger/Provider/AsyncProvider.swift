//
//  AsyncProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import Combine
import LogMacro

public class AsyncProvider<T: TargetType & Sendable> {
	private let session: URLSession
	private let maxRetryCount = 3
	private let retryDelay: TimeInterval = 2.0  // 재시도 간격 (2초)
	
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	public func requestAsync<D: Decodable & Sendable>(
		_ target: T
	) async throws -> D {
		let request = URLRequestBuilder.buildRequest(from: target)
		return try await executeWithRetry(request: request, retryCount: 0)
	}
    
    /// `requestAsync`와 동일하지만 더 짧은 이름을 선호하는 경우 사용합니다.
    public func request<D: Decodable & Sendable>(
        _ target: T
    ) async throws -> D {
        try await requestAsync(target)
    }

	private func executeWithRetry<D: Decodable & Sendable>(
		request: URLRequest,
		retryCount: Int
	) async throws -> D {
		do {
			let (data, response) = try await session.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				Log.error("No HTTP response received")
				throw DataError.noData
			}
			
			let statusCode = httpResponse.statusCode
			
			switch statusCode {
			case 200...299:
				return try data.decoded(as: D.self)
			case 400..<500:
				if let respError = try? data.decoded(as: ResponseError.self) {
					let desc = respError.description
					Log.error("Client Error (\(statusCode)) for URL: \(request.url?.absoluteString ?? "No URL") | \(desc)")
					throw DataError.customError(desc)
				}
				Log.error("Client Error (\(statusCode)) for URL: \(request.url?.absoluteString ?? "No URL")")
				throw DataError.statusCodeError(statusCode)
			case 500..<600:
				Log.error("Server Error (\(statusCode)) for URL: \(request.url?.absoluteString ?? "No URL")")
				throw DataError.statusCodeError(statusCode)
			default:
				Log.error("Unhandled status code: \(statusCode) for URL: \(request.url?.absoluteString ?? "No URL")")
				throw DataError.unhandledStatusCode(statusCode)
			}
		} catch {
			Log.error("Network request failed with error: \(error.localizedDescription)")
			
			// 상태 코드 기반 오류는 재시도하지 않음
			if error is DataError {
				throw error
			}
			
			if retryCount < maxRetryCount {
				// 대기 후 재시도
				try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))  // 대기 시간
				return try await executeWithRetry(request: request, retryCount: retryCount + 1)
			} else {
				throw error  // 재시도 횟수를 초과한 경우 원래 에러를 던짐
			}
		}
	}
	
	private func decodeErrorResponseData<D: Decodable>(data: Data) throws -> D {
		let decoder = JSONDecoder()
		
		// 데이터를 제네릭 D 타입으로 디코딩 시도
		if let decodedData = try? decoder.decode(D.self, from: data) {
			Log.debug("Successfully decoded response: \(decodedData)")
			return decodedData
		} else {
			Log.error("Failed to decode response as type \(D.self)")
			throw URLError(.cannotParseResponse)
		}
	}
}

extension AsyncProvider: @unchecked Sendable {}
