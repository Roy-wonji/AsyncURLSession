//
//  AsyncURLProvider.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncURLProvider<T: TargetType> {
    private let session: URLSession

        init(session: URLSession = .shared) {
            self.session = session
        }
        
        public func requestAsync<D: Decodable & Sendable>(_ target: T, decodeTo type: D.Type) async throws -> D? {
            let request = URLRequestBuilder.buildRequest(from: target)
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DataError.noData
            }
            switch httpResponse.statusCode {
            case 200, 201, 204:
                return try? data.decoded(as: D.self)
            case 400:
                throw DataError.customError("Bad Request (400)")
            case 404:
                throw DataError.customError("Not Found (404)")
            default:
                throw DataError.unhandledStatusCode(httpResponse.statusCode)
            }
        }
}
