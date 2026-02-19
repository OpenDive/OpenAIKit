import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAITransportOptionsTests: XCTestCase {
    func testConfigurationHeadersIncludeOrganizationProjectAndCustomHeaders() {
        let config = Configuration(
            apiKey: "test_key",
            organizationId: "org_test",
            projectId: "proj_test",
            webhookSecret: "whsec_test",
            baseURL: URL(string: "https://example.com/v1")!,
            requestOptions: OpenAIRequestOptions(
                timeoutInterval: 42,
                maxRetries: 3,
                additionalHeaders: ["X-Test-Header": "value"]
            )
        )

        let headers = OpenAIKitSession.shared.headers(for: config)

        XCTAssertEqual(headers["Authorization"], "Bearer test_key")
        XCTAssertEqual(headers["OpenAI-Organization"], "org_test")
        XCTAssertEqual(headers["OpenAI-Project"], "proj_test")
        XCTAssertEqual(headers["X-Test-Header"], "value")
    }

    func testStatusErrorMappingUsesTypedCases() {
        let payload = """
        {
          "error": {
            "message": "invalid request",
            "type": "invalid_request_error",
            "param": null,
            "code": "bad_request"
          }
        }
        """.data(using: .utf8)!

        let badRequest = OpenAIKitSession.statusError(for: 400, data: payload)
        if case .badRequest(let response) = badRequest {
            XCTAssertEqual(response?.error.message, "invalid request")
        } else {
            XCTFail("Expected .badRequest")
        }

        let unauthorized = OpenAIKitSession.statusError(for: 401, data: payload)
        if case .authentication = unauthorized {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .authentication")
        }

        let rateLimited = OpenAIKitSession.statusError(for: 429, data: payload)
        if case .rateLimit = rateLimited {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .rateLimit")
        }

        let server = OpenAIKitSession.statusError(for: 503, data: payload)
        if case .internalServer(let code, _) = server {
            XCTAssertEqual(code, 503)
        } else {
            XCTFail("Expected .internalServer")
        }

        let unexpected = OpenAIKitSession.statusError(for: 418, data: payload)
        if case .unexpectedStatusCode(let code, _) = unexpected {
            XCTAssertEqual(code, 418)
        } else {
            XCTFail("Expected .unexpectedStatusCode")
        }
    }
}
