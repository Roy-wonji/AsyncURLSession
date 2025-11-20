//
//  URLRequestBuilder.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import LogMacro

// URL 요청을 생성하는 클래스
public class URLRequestBuilder {
	public init() {}

	static func buildRequest(from target: TargetType) -> URLRequest {
		// URL 생성 시 불필요한 공백을 제거하기 위한 trim 적용
		let url = target.baseURL.appendingPathComponent(target.path.trimmingCharacters(in: .whitespaces))
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
					Log.error("Failed to encode parameters: %{public}@", error.localizedDescription)
				}
			case .requestData(let data):
				request.httpBody = data
			case .requestJSONEncodable(let encodable):
				do {
					request.httpBody = try encodable.toJSONData()
					addDefaultJSONHeaderIfNeeded(to: &request)
				} catch {
					Log.error("Failed to encode JSON body: %{public}@", error.localizedDescription)
				}
			case .requestCustomJSONEncodable(let encodable, let encoder):
				do {
					request.httpBody = try encodable.toJSONData(using: encoder)
					addDefaultJSONHeaderIfNeeded(to: &request)
				} catch {
					Log.error("Failed to encode custom JSON body: %{public}@", error.localizedDescription)
				}
			case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
				do {
					components?.queryItems = urlParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
					request.url = components?.url
					request = try bodyEncoding.encode(request, with: bodyParameters)
				} catch {
					Log.error("Failed to encode composite parameters: %{public}@", error.localizedDescription)
				}
			case .requestCompositeData(let bodyData, let urlParameters):
				components?.queryItems = urlParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
				request.url = components?.url
				request.httpBody = bodyData
			case .uploadFile(let fileURL):
				do {
					request.httpBody = try Data(contentsOf: fileURL)
				} catch {
					Log.error("Failed to read file data for upload: %{public}@", error.localizedDescription)
				}
			case .requestPlain:
				// No parameters should be added for requestPlain, ignoring any accidental parameters
				components?.queryItems = nil
				request.url = components?.url
		}

		return request
	}

	private static func addDefaultJSONHeaderIfNeeded(to request: inout URLRequest) {
		// Content-Type이 없는 경우에만 기본 JSON 헤더를 추가합니다.
		if request.value(forHTTPHeaderField: "Content-Type") == nil {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}
	}
}
