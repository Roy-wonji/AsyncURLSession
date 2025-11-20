//
//  NetworkEventMonitor.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public protocol NetworkEventMonitor: Sendable {
    func requestDidStart(
        _ request: URLRequest,
        id: String
    ) async
    
    func requestDidFinish(
        _ request: URLRequest,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        duration: TimeInterval,
        id: String
    ) async
}

/// 네트워크 요청/응답을 로깅하는 Monitor
public final class LoggerEventMonitor: NetworkEventMonitor {
    private let logger: NetworkLogger
    
    public init(logger: NetworkLogger = NetworkLogger()) {
        self.logger = logger
    }
    
    public func requestDidStart(
        _ request: URLRequest,
        id: String
    ) async {
        await logger.addRequestLog(request, id: id)
    }
    
    public func requestDidFinish(
        _ request: URLRequest,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        duration: TimeInterval,
        id: String
    ) async {
        if let error = error {
            await logger.addErrorLog(error, duration: duration, id: id)
        } else if let response = response {
            await logger.addResponseLog(response, data: data, duration: duration, id: id)
        }
    }
}
