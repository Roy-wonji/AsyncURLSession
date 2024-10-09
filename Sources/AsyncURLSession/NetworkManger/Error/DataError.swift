//
//  DataError.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

// 데이터 오류 정의
public enum DataError: Error {
    case noData
    case customError(String)
    case unhandledStatusCode(Int)
    case httpResponseError(HTTPURLResponse, String)
}
