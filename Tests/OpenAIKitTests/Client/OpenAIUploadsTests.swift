import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIUploadsTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testUploadCompleteParametersEncodePartIds() throws {
        let params = UploadCompleteParameters(partIDs: ["part_1", "part_2"])
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let partIDs = object["part_ids"] as? [String]
        XCTAssertEqual(partIDs?.count, 2)
    }

    func testUploadMethodsAreExposed() {
        let client = makeClient()

        let createUpload: (UploadCreateParameters) async throws -> UploadObject = client.uploads.create
        let retrieveUpload: (String) async throws -> UploadObject = client.uploads.retrieve
        let cancelUpload: (String) async throws -> UploadObject = client.uploads.cancel
        let completeUpload: (String, UploadCompleteParameters) async throws -> UploadObject = client.uploads.complete
        let createPart: (String, UploadPartCreateParameters) async throws -> UploadPartObject = client.uploads.parts.create

        XCTAssertNotNil(createUpload)
        XCTAssertNotNil(retrieveUpload)
        XCTAssertNotNil(cancelUpload)
        XCTAssertNotNil(completeUpload)
        XCTAssertNotNil(createPart)
    }
}
