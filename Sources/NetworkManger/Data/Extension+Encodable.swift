//
//  Extension+Encodable.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/11/24.
//

import Foundation

public extension Encodable {
	/// Encodable 타입을 JSON 데이터로 변환합니다.
	func toJSONData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
		try encoder.encode(self)
	}
}
