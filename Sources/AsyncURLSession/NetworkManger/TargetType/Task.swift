//
//  Task.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation

public enum Task {
    case requestPlain
    case requestData(Data)
    case requestJSONEncodable(Encodable)
    case requestCustomJSONEncodable(Encodable, encoder: JSONEncoder)
    case requestParameters(parameters: [String: Any], encoding: CustomParameterEncoding)
    case requestCompositeData(bodyData: Data, urlParameters: [String: Any])
    case requestCompositeParameters(bodyParameters: [String: Any], bodyEncoding: CustomParameterEncoding, urlParameters: [String: Any])
    case uploadFile(URL)
}

