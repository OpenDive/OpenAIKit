import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIClientScaffoldTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testTopLevelResourcesAreAccessible() {
        let client = makeClient()

        XCTAssertNotNil(client.completions)
        XCTAssertNotNil(client.chat)
        XCTAssertNotNil(client.embeddings)
        XCTAssertNotNil(client.files)
        XCTAssertNotNil(client.images)
        XCTAssertNotNil(client.audio)
        XCTAssertNotNil(client.moderations)
        XCTAssertNotNil(client.models)
        XCTAssertNotNil(client.fineTuning)
        XCTAssertNotNil(client.vectorStores)
        XCTAssertNotNil(client.webhooks)
        XCTAssertNotNil(client.beta)
        XCTAssertNotNil(client.batches)
        XCTAssertNotNil(client.uploads)
        XCTAssertNotNil(client.responses)
        XCTAssertNotNil(client.realtime)
        XCTAssertNotNil(client.conversations)
        XCTAssertNotNil(client.evals)
        XCTAssertNotNil(client.containers)
        XCTAssertNotNil(client.skills)
        XCTAssertNotNil(client.videos)
    }

    func testNestedResourcesAreAccessible() {
        let client = makeClient()

        XCTAssertNotNil(client.chat.completions)
        XCTAssertNotNil(client.audio.speech)
        XCTAssertNotNil(client.audio.transcriptions)
        XCTAssertNotNil(client.audio.translations)
        XCTAssertNotNil(client.vectorStores.files)
        XCTAssertNotNil(client.vectorStores.fileBatches)
        XCTAssertNotNil(client.uploads.parts)
        XCTAssertNotNil(client.responses.inputItems)
        XCTAssertNotNil(client.responses.inputTokens)
        XCTAssertNotNil(client.realtime.calls)
        XCTAssertNotNil(client.realtime.clientSecrets)
        XCTAssertNotNil(client.conversations.items)
        XCTAssertNotNil(client.evals.runs.outputItems)
        XCTAssertNotNil(client.containers.files.content)
        XCTAssertNotNil(client.skills.versions.content)
        XCTAssertNotNil(client.skills.content)
        XCTAssertNotNil(client.beta.assistants)
        XCTAssertNotNil(client.beta.threads.messages)
        XCTAssertNotNil(client.beta.threads.runs.steps)
        XCTAssertNotNil(client.beta.chatkit.sessions)
        XCTAssertNotNil(client.beta.chatkit.threads)
        XCTAssertNotNil(client.beta.realtime.sessions)
        XCTAssertNotNil(client.beta.realtime.transcriptionSessions)
    }
}
