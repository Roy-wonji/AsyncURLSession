//
//  TargetType+Request.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public extension TargetType {
	/// 빌더를 통해 `URLRequest`를 생성합니다.
	func asURLRequest() throws -> URLRequest {
		URLRequestBuilder.buildRequest(from: self)
	}
}
