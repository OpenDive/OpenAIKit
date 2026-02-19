import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIBatchesTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testBatchCreateParametersEncodeInputFileId() throws {
        let params = BatchCreateParameters(
            inputFileID: "file_123",
            endpoint: "/v1/responses",
            completionWindow: "24h"
        )
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["input_file_id"] as? String, "file_123")
        XCTAssertEqual(object["endpoint"] as? String, "/v1/responses")
        XCTAssertEqual(object["completion_window"] as? String, "24h")
    }

    func testBatchMethodsAreExposed() {
        let client = makeClient()

        let createBatch: (BatchCreateParameters) async throws -> BatchObject = client.batches.create
        let listBatches: () async throws -> BatchListResponse = client.batches.list
        let retrieveBatch: (String) async throws -> BatchObject = client.batches.retrieve
        let cancelBatch: (String) async throws -> BatchObject = client.batches.cancel

        XCTAssertNotNil(createBatch)
        XCTAssertNotNil(listBatches)
        XCTAssertNotNil(retrieveBatch)
        XCTAssertNotNil(cancelBatch)
    }
}
