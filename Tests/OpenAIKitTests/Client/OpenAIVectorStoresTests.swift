import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIVectorStoresTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testVectorStoreParametersEncodeFileIdsKey() throws {
        let createParams = VectorStoreCreateParameters(name: "Docs", fileIDs: ["file_1", "file_2"])
        let createData = try JSONEncoder().encode(createParams)
        let createObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: createData) as? [String: Any])
        XCTAssertNotNil(createObject["file_ids"])

        let fileParams = VectorStoreFileCreateParameters(fileID: "file_123")
        let fileData = try JSONEncoder().encode(fileParams)
        let fileObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: fileData) as? [String: Any])
        XCTAssertEqual(fileObject["file_id"] as? String, "file_123")
    }

    func testVectorStoreMethodsAreExposed() {
        let client = makeClient()

        let createStore: (VectorStoreCreateParameters) async throws -> VectorStoreObject = client.vectorStores.create
        let listStores: () async throws -> VectorStoreListResponse = client.vectorStores.list
        let retrieveStore: (String) async throws -> VectorStoreObject = client.vectorStores.retrieve
        let updateStore: (String, VectorStoreUpdateParameters) async throws -> VectorStoreObject = client.vectorStores.update
        let deleteStore: (String) async throws -> DeleteObject = client.vectorStores.delete

        let createFile: (String, VectorStoreFileCreateParameters) async throws -> VectorStoreFileObject = client.vectorStores.files.create
        let listFiles: (String) async throws -> VectorStoreFileListResponse = client.vectorStores.files.list
        let retrieveFile: (String, String) async throws -> VectorStoreFileObject = client.vectorStores.files.retrieve
        let deleteFile: (String, String) async throws -> DeleteObject = client.vectorStores.files.delete

        let createBatch: (String, VectorStoreFileBatchCreateParameters) async throws -> VectorStoreFileBatchObject = client.vectorStores.fileBatches.create
        let listBatches: (String) async throws -> VectorStoreFileBatchListResponse = client.vectorStores.fileBatches.list
        let retrieveBatch: (String, String) async throws -> VectorStoreFileBatchObject = client.vectorStores.fileBatches.retrieve
        let cancelBatch: (String, String) async throws -> VectorStoreFileBatchObject = client.vectorStores.fileBatches.cancel

        XCTAssertNotNil(createStore)
        XCTAssertNotNil(listStores)
        XCTAssertNotNil(retrieveStore)
        XCTAssertNotNil(updateStore)
        XCTAssertNotNil(deleteStore)
        XCTAssertNotNil(createFile)
        XCTAssertNotNil(listFiles)
        XCTAssertNotNil(retrieveFile)
        XCTAssertNotNil(deleteFile)
        XCTAssertNotNil(createBatch)
        XCTAssertNotNil(listBatches)
        XCTAssertNotNil(retrieveBatch)
        XCTAssertNotNil(cancelBatch)
    }
}
