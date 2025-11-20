import XCTest
@testable import AsyncURLSession

final class AsyncURLSessionTests: XCTestCase {

    func testBaseTargetTypeBuildsRequestWithQueryParameters() throws {
        let target = TestTarget.getItem(id: 42)
        let request = try target.asURLRequest()

        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertEqual(request.url?.absoluteString, "https://api.test.com/v1/items?id=42")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testBaseTargetTypeBuildsRequestWithJSONBody() throws {
        let payload: [String: Any] = ["name": "foo", "count": 1]
        let target = TestTarget.createItem(payload: payload)
        let request = try target.asURLRequest()

        XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
        XCTAssertEqual(request.url?.absoluteString, "https://api.test.com/v1/items/create")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")

        guard let body = request.httpBody else {
            XCTFail("Body should not be nil")
            return
        }
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(json?["name"] as? String, "foo")
        XCTAssertEqual(json?["count"] as? Int, 1)
    }
}

// MARK: - Test helpers
struct DummyDomain: DomainType {
    let url: String = "/v1"
    let baseURLString: String = "https://api.test.com"
}

enum TestTarget: BaseTargetType, @unchecked Sendable {
    case getItem(id: Int)
    case createItem(payload: [String: Any])

    typealias Domain = DummyDomain
    var domain: DummyDomain { DummyDomain() }

    var urlPath: String {
        switch self {
        case .getItem:
            return "/items"
        case .createItem:
            return "/items/create"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getItem:
            return .get
        case .createItem:
            return .post
        }
    }

    var error: [Int : NetworkError]? { nil }

    var parameters: [String : Any]? {
        switch self {
        case .getItem(let id):
            return ["id": id]
        case .createItem(let payload):
            return payload
        }
    }
}
