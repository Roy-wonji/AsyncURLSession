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
            var request = URLRequest(url: components?.url ?? url)
            request.httpMethod = target.method.rawValue

            if let headers = target.headers {
                headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
            }

            switch target.task {
            case .requestParameters(let parameters, let encoding):
                do {
                    request = try encoding.encode(request, with: parameters)
                } catch {
                    Log.error("Failed to encode parameters: \(error.localizedDescription)")
                }
            case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
                do {
                    components?.queryItems = urlParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components?.url
                    request = try bodyEncoding.encode(request, with: bodyParameters)
                } catch {
                    Log.error("Failed to encode composite parameters: \(error.localizedDescription)")
                }
            case .requestPlain:
                
                components?.queryItems = nil
                request.url = components?.url
            default:
                break
            }

            return request
        }
}
