import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIBetaAssistantsTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testThreadRunCreateParametersEncodeAssistantId() throws {
        let params = ThreadRunCreateParameters(assistantId: "asst_123", model: "gpt-4o-mini")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["assistant_id"] as? String, "asst_123")
        XCTAssertEqual(object["model"] as? String, "gpt-4o-mini")
    }

    func testBetaAssistantAndThreadMethodsAreExposed() {
        let client = makeClient()

        let createAssistant: (AssistantCreateParameters) async throws -> AssistantObject = client.beta.assistants.create
        let listAssistants: () async throws -> AssistantListResponse = client.beta.assistants.list
        let retrieveAssistant: (String) async throws -> AssistantObject = client.beta.assistants.retrieve
        let updateAssistant: (String, AssistantUpdateParameters) async throws -> AssistantObject = client.beta.assistants.update
        let deleteAssistant: (String) async throws -> DeleteObject = client.beta.assistants.delete

        let createThread: (ThreadCreateParameters) async throws -> ThreadObject = client.beta.threads.create
        let retrieveThread: (String) async throws -> ThreadObject = client.beta.threads.retrieve
        let updateThread: (String, ThreadUpdateParameters) async throws -> ThreadObject = client.beta.threads.update
        let deleteThread: (String) async throws -> DeleteObject = client.beta.threads.delete

        let createRun: (String, ThreadRunCreateParameters) async throws -> ThreadRunObject = client.beta.threads.runs.create
        let listRuns: (String) async throws -> ThreadRunListResponse = client.beta.threads.runs.list
        let retrieveRun: (String, String) async throws -> ThreadRunObject = client.beta.threads.runs.retrieve
        let cancelRun: (String, String) async throws -> ThreadRunObject = client.beta.threads.runs.cancel

        let listSteps: (String, String) async throws -> ThreadRunStepListResponse = client.beta.threads.runs.steps.list
        let retrieveStep: (String, String, String) async throws -> ThreadRunStepObject = client.beta.threads.runs.steps.retrieve

        XCTAssertNotNil(createAssistant)
        XCTAssertNotNil(listAssistants)
        XCTAssertNotNil(retrieveAssistant)
        XCTAssertNotNil(updateAssistant)
        XCTAssertNotNil(deleteAssistant)
        XCTAssertNotNil(createThread)
        XCTAssertNotNil(retrieveThread)
        XCTAssertNotNil(updateThread)
        XCTAssertNotNil(deleteThread)
        XCTAssertNotNil(createRun)
        XCTAssertNotNil(listRuns)
        XCTAssertNotNil(retrieveRun)
        XCTAssertNotNil(cancelRun)
        XCTAssertNotNil(listSteps)
        XCTAssertNotNil(retrieveStep)
    }
}
