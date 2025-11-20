//
//  NetworkLogger.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation
import LogMacro

/// Log struct를 활용하는 간단한 네트워크 로거 Actor
public actor NetworkLogger {
	public init() {}

	public func addRequestLog(_ request: URLRequest, id: String) {
		let method = request.httpMethod ?? "UNKNOWN"
		let urlString = request.url?.absoluteString ?? "NO_URL"
		Log.network("[Request] id: \(id) | \(method) \(urlString)")
		if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
			Log.debug("[Request-Header] id: \(id) | \(headers)")
		}
		if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
			Log.debug("[Request-Body] id: \(id) | \(bodyString)")
		}
	}

	public func addResponseLog(_ response: HTTPURLResponse, data: Data?, duration: TimeInterval, id: String) {
		Log.network("[Response] id: \(id) | status: \(response.statusCode) | time: \(String(format: "%.3f", duration))s")
		if let data = data, let bodyString = String(data: data, encoding: .utf8) {
			Log.debug("[Response-Body] id: \(id) | \(bodyString)")
		}
	}

	public func addErrorLog(_ error: Error, duration: TimeInterval, id: String) {
		Log.error("[Error] id: \(id) | time: \(String(format: "%.3f", duration))s | \(error.localizedDescription)")
	}
}
