//
//  BaseTargetType.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public protocol DomainType: Sendable {
    var url: String { get }
    var baseURLString: String { get }
}

public protocol BaseTargetType: TargetType {
    associatedtype Domain: DomainType
    var domain: Domain { get }
    var urlPath: String { get }
    var error: [Int: NetworkError]? { get }
    var parameters: [String: Any]? { get }
}

public extension BaseTargetType {
    var baseURL: URL { URL(string: domain.baseURLString)! }
    var path: String { domain.url + urlPath }

    var headers: [String: String]? { APIHeaders.cached }

    var task: NetworkTask {
        if let parameters {
            return method == .get
            ? .requestParameters(parameters: parameters, encoding: .url)
            : .requestParameters(parameters: parameters, encoding: .json)
        }
        return .requestPlain
    }
}

// MARK: - Static header cache
public enum APIHeaders {
    public static let cached: [String: String] = [
        "Content-Type": "application/json"
    ]
}
