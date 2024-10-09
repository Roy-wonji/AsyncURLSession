//
//  CustomParameterEncoding.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

public enum CustomParameterEncoding {
    case url
    case json
    
    func encode(_ request: URLRequest, with parameters: [String: Any]) throws -> URLRequest {
        var request = request
        switch self {
        case .url:
            guard let url = request.url else { throw DataError.customError("Invalid URL") }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = components?.url
        case .json:
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
