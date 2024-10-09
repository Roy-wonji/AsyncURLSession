//
//  AsyncURLProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncURLProvider {
    public init() {}

    public func requestAsync<T: Decodable & Sendable>(
        _ target: TargetType,
        decodeTo type: T.Type
    ) async throws -> T? {
            let request = URLRequestBuilder.buildRequest(from: target)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DataError.noData
            }
            switch httpResponse.statusCode {
            case 200, 201, 204:
                return try data.decoded(as: T.self)
            case 400:
                throw DataError.customError("Bad Request (400)")
            case 404:
                throw DataError.customError("Not Found (404)")
            default:
                throw DataError.unhandledStatusCode(httpResponse.statusCode)
            }
        }
    
}
