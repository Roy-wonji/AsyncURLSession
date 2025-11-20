//
//  URLRequestConvertible.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public protocol URLRequestConvertible {
	func asURLRequest() throws -> URLRequest
}
