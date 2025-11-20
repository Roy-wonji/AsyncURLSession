//
//  ResponseError.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

/// 서버가 내려주는 기본 에러 포맷을 디코드하기 위한 타입
public struct ResponseError: Decodable {
    public let message: String?
    public let code: String?
    
    public init(message: String? = nil, code: String? = nil) {
        self.message = message
        self.code = code
    }

    public var description: String {
        let msg = message ?? "Unknown error"
        if let code { return "\(msg) (code: \(code))" }
        return msg
    }
}
