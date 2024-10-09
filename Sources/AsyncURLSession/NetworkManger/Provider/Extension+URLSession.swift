//
//  Extension+URLSession.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

@available(iOS 9.0, macOS 9.0, *)
extension URLSession {
    func dataResult(for request: URLRequest, completion: @escaping @Sendable (Result<(Data, URLResponse), Error>) -> Void) {
        let task = self.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response {
                completion(.success((data, response)))
            } else {
                let unknownError = NSError(domain: "Unknown error", code: -1, userInfo: nil)
                completion(.failure(unknownError))
            }
        }
        task.resume()
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension URLSession {
    func dataResult(for request: URLRequest) async -> Result<(Data, URLResponse), Error> {
        do {
            let (data, response) = try await self.data(for: request)
            return .success((data, response))
        } catch {
            return .failure(error)
        }
    }
}
