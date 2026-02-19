import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIFineTuningTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testFineTuningParametersEncodeTrainingFileKey() throws {
        let params = FineTuningJobCreateParameters(
            model: "gpt-4o-mini",
            trainingFileID: "file_train",
            validationFileID: "file_val"
        )
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["training_file"] as? String, "file_train")
        XCTAssertEqual(object["validation_file"] as? String, "file_val")
    }

    func testFineTuningMethodsAreExposed() {
        let client = makeClient()

        let createJob: (FineTuningJobCreateParameters) async throws -> FineTuningJobObject = client.fineTuning.jobs.create
        let listJobs: () async throws -> FineTuningJobListResponse = client.fineTuning.jobs.list
        let retrieveJob: (String) async throws -> FineTuningJobObject = client.fineTuning.jobs.retrieve
        let cancelJob: (String) async throws -> FineTuningJobObject = client.fineTuning.jobs.cancel
        let listEvents: (String) async throws -> FineTuningJobEventListResponse = client.fineTuning.jobs.listEvents
        let listCheckpoints: (String) async throws -> FineTuningCheckpointListResponse = client.fineTuning.jobs.listCheckpoints

        XCTAssertNotNil(createJob)
        XCTAssertNotNil(listJobs)
        XCTAssertNotNil(retrieveJob)
        XCTAssertNotNil(cancelJob)
        XCTAssertNotNil(listEvents)
        XCTAssertNotNil(listCheckpoints)
    }
}
