//
//  URLRequestBuilder.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

public class URLRequestBuilder {
    public init() {}
    
    static func buildRequest(from target: TargetType) -> URLRequest {
        let url = target.baseURL.appendingPathComponent(target.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if target.method == .get, let parameters = target.parameters {
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        var request = URLRequest(url: components?.url ?? url)
        request.httpMethod = target.method.rawValue

        if let headers = target.headers {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }

        if target.method != .get, let parameters = target.parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
