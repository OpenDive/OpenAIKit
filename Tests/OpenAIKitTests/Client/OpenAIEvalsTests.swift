import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIEvalsTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testEvalRunCreateParametersEncodeInput() throws {
        let params = EvalRunCreateParameters(input: "sample-input", model: "gpt-5.2")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["input"] as? String, "sample-input")
        XCTAssertEqual(object["model"] as? String, "gpt-5.2")
    }

    func testEvalMethodsAreExposed() {
        let client = makeClient()

        let createEval: (EvalCreateParameters) async throws -> EvalObject = client.evals.create
        let listEvals: () async throws -> EvalListResponse = client.evals.list
        let retrieveEval: (String) async throws -> EvalObject = client.evals.retrieve
        let deleteEval: (String) async throws -> DeleteObject = client.evals.delete

        let createRun: (String, EvalRunCreateParameters) async throws -> EvalRunObject = client.evals.runs.create
        let listRuns: (String) async throws -> EvalRunListResponse = client.evals.runs.list
        let retrieveRun: (String, String) async throws -> EvalRunObject = client.evals.runs.retrieve
        let cancelRun: (String, String) async throws -> EvalRunObject = client.evals.runs.cancel
        let listOutputItems: (String, String) async throws -> EvalRunOutputItemListResponse = client.evals.runs.outputItems.list

        XCTAssertNotNil(createEval)
        XCTAssertNotNil(listEvals)
        XCTAssertNotNil(retrieveEval)
        XCTAssertNotNil(deleteEval)
        XCTAssertNotNil(createRun)
        XCTAssertNotNil(listRuns)
        XCTAssertNotNil(retrieveRun)
        XCTAssertNotNil(cancelRun)
        XCTAssertNotNil(listOutputItems)
    }
}
