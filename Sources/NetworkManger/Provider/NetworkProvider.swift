//
//  NetworkProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

@MainActor
public final class NetworkProvider {
	private let session: URLSession
	private var eventMonitors: [NetworkEventMonitor]
	
	public static let `default` = NetworkProvider()
	
	public init(
		session: URLSession = .shared,
		eventMonitors: [NetworkEventMonitor] = [LoggerEventMonitor()]
	) {
		self.session = session
		self.eventMonitors = eventMonitors
	}
	
	// MARK: - Public Request (with Decodable)
	public func request<T: Decodable>(
		_ urlConvertible: URLRequestConvertible
	) async throws -> T {
		let requestID = UUID().uuidString.prefix(8).uppercased()
		let request = try urlConvertible.asURLRequest()
		notifyStart(request, id: String(requestID))
		let data = try await performRequest(request, requestID: String(requestID))
		return try decode(data)
	}
	
	// MARK: - Public Request (void)
	public func request(
		_ urlConvertible: URLRequestConvertible
	) async throws {
		let requestID = UUID().uuidString.prefix(8).uppercased()
		let request = try urlConvertible.asURLRequest()
		notifyStart(request, id: String(requestID))
		_ = try await performRequest(request, requestID: String(requestID))
	}
	
	// MARK: - Private helpers
	@discardableResult
	private func performRequest(
		_ request: URLRequest,
		requestID: String
	) async throws -> Data {
		let startTime = Date()
        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            let statusCode = httpResponse.statusCode
            guard (200...299).contains(statusCode) else {
                let errorToThrow: Error

                switch statusCode {
                case 400..<500:
                    if let respError = try? data.decoded(as: ResponseError.self) {
                        errorToThrow = DataError.customError(respError.description)
                    } else {
                        errorToThrow = DataError.statusCodeError(statusCode)
                    }
                case 500..<600:
                    errorToThrow = DataError.statusCodeError(statusCode)
                default:
                    errorToThrow = DataError.unhandledStatusCode(statusCode)
                }

                notifyFinish(request, response: httpResponse, data: data, error: errorToThrow, duration: duration, id: requestID)
                throw errorToThrow
            }

            notifyFinish(request, response: httpResponse, data: data, error: nil, duration: duration, id: requestID)
            return data
        } catch {
            let duration = Date().timeIntervalSince(startTime)

            // 이미 위에서 처리한 DataError는 중복 notify 없이 그대로 전달
            if error is DataError {
                throw error
            }

            let networkError = error as? NetworkError ?? NetworkError.unknown(error)
            var response: HTTPURLResponse?
            var data: Data?
            if case .httpError(_, let res, let respData) = networkError {
                response = res
				data = respData
			}
			notifyFinish(request, response: response, data: data, error: networkError, duration: duration, id: requestID)
			throw networkError
		}
	}
	
	private func decode<T: Decodable>(_ data: Data) throws -> T {
		do {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			return try data.decoded(as: T.self, decoder: decoder)
		} catch {
			throw NetworkError.decodingError(error)
		}
	}
	
	private func notifyStart(_ request: URLRequest, id: String) {
        eventMonitors.forEach { monitor in
            Task { await monitor.requestDidStart(request, id: id) }
        }
	}
	
	private func notifyFinish(
		_ request: URLRequest,
		response: HTTPURLResponse?,
		data: Data?,
		error: Error?,
		duration: TimeInterval,
		id: String
	) {
        eventMonitors.forEach { monitor in
            Task {
                await monitor.requestDidFinish(
                    request,
                    response: response,
                    data: data,
                    error: error,
                    duration: duration,
                    id: id
                )
            }
        }
	}
}

// MARK: - TargetType 편의 API
public extension NetworkProvider {
	func request<T: Decodable>(_ target: TargetType) async throws -> T {
		try await request(target as URLRequestConvertible)
	}
	
	func request(_ target: TargetType) async throws {
		try await request(target as URLRequestConvertible)
	}
}
