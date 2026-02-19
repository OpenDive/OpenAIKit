import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIResponsesTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testResponseInputTokenParametersEncode() throws {
        let params = ResponseInputTokensParameters(model: "gpt-5.2", input: "hello")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["model"] as? String, "gpt-5.2")
        XCTAssertEqual(object["input"] as? String, "hello")
    }

    func testResponseResourceMethodsAreExposed() {
        let client = makeClient()

        let createResponse: (ResponseCreateParameters) async throws -> ResponseObject = client.responses.create
        let parseResponse: (ResponseCreateParameters) async throws -> ResponseObject = client.responses.parse
        let streamResponse: (ResponseCreateParameters) throws -> AsyncThrowingStream<ResponseObject, Error> = client.responses.stream
        let retrieveResponse: (String) async throws -> ResponseObject = client.responses.retrieve
        let cancelResponse: (String) async throws -> ResponseObject = client.responses.cancel
        let deleteResponse: (String) async throws -> DeleteObject = client.responses.delete

        let listInputItems: (String) async throws -> ResponseInputItemListResponse = client.responses.inputItems.list
        let countInputTokens: (ResponseInputTokensParameters) async throws -> ResponseInputTokenCount = client.responses.inputTokens.create

        XCTAssertNotNil(createResponse)
        XCTAssertNotNil(parseResponse)
        XCTAssertNotNil(streamResponse)
        XCTAssertNotNil(retrieveResponse)
        XCTAssertNotNil(cancelResponse)
        XCTAssertNotNil(deleteResponse)
        XCTAssertNotNil(listInputItems)
        XCTAssertNotNil(countInputTokens)
    }
}
