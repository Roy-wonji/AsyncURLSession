//
//  Extension+URLSession.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation


@available(iOS 13.0.0, *)
extension URLSession {
    // URLSession의 data(for:)를 Result 타입으로 반환하는 헬퍼 함수
    func dataResult(for request: URLRequest) async -> Result<(Data, URLResponse), Error> {
        do {
            let (data, response) = try await self.data(for: request)
            return .success((data, response))
        } catch {
            return .failure(error)
        }
    }
}
