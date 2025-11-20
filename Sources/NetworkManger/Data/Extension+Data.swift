//
//  Extension+Data.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import LogMacro

extension Data {
	//MARK: -  async/ await 으로 디코딩
	func decoded<T: Decodable>(as type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
		return try decoder.decode(T.self, from: self)
	}

	func decodeData<T: Decodable>(as type: T.Type, forStatusCode statusCode: Int) throws -> T {
		let decoder = JSONDecoder()
		do {
			return try decoder.decode(T.self, from: self)
		} catch {
			Log.error("Failed to decode response with status code: \(statusCode)")
			throw DataError.noData
		}
	}
}
