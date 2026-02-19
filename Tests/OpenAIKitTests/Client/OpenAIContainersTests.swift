import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIContainersTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testContainerFileCreateParametersEncodeFileId() throws {
        let params = ContainerFileCreateParameters(fileID: "file_123")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["file_id"] as? String, "file_123")
    }

    func testContainerMethodsAreExposed() {
        let client = makeClient()

        let createContainer: (ContainerCreateParameters) async throws -> ContainerObject = client.containers.create
        let listContainers: () async throws -> ContainerListResponse = client.containers.list
        let retrieveContainer: (String) async throws -> ContainerObject = client.containers.retrieve
        let deleteContainer: (String) async throws -> DeleteObject = client.containers.delete

        let createContainerFile: (String, ContainerFileCreateParameters) async throws -> ContainerFileObject = client.containers.files.create
        let listContainerFiles: (String) async throws -> ContainerFileListResponse = client.containers.files.list
        let retrieveContainerFile: (String, String) async throws -> ContainerFileObject = client.containers.files.retrieve
        let deleteContainerFile: (String, String) async throws -> DeleteObject = client.containers.files.delete
        let retrieveContainerFileContent: (String, String) async throws -> Data = client.containers.files.content.retrieve

        XCTAssertNotNil(createContainer)
        XCTAssertNotNil(listContainers)
        XCTAssertNotNil(retrieveContainer)
        XCTAssertNotNil(deleteContainer)
        XCTAssertNotNil(createContainerFile)
        XCTAssertNotNil(listContainerFiles)
        XCTAssertNotNil(retrieveContainerFile)
        XCTAssertNotNil(deleteContainerFile)
        XCTAssertNotNil(retrieveContainerFileContent)
    }
}
