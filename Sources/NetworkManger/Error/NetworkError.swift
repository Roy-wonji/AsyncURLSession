//
//  NetworkError.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public enum NetworkError: Error {
	case invalidResponse
	case httpError(statusCode: Int, response: HTTPURLResponse, data: Data?)
	case decodingError(Error)
	case unknown(Error)
}
