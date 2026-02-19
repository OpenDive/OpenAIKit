import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIRealtimeTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testRealtimeReferParameterEncoding() throws {
        let params = RealtimeCallReferParameters(target: "agent-2", reason: "escalation")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["target"] as? String, "agent-2")
        XCTAssertEqual(object["reason"] as? String, "escalation")
    }

    func testRealtimeMethodsAreExposed() async throws {
        let client = makeClient()

        let createCall: (RealtimeCallCreateParameters) async throws -> RealtimeCallObject = client.realtime.calls.create
        let acceptCall: (String) async throws -> RealtimeCallObject = client.realtime.calls.accept
        let hangupCall: (String) async throws -> RealtimeCallObject = client.realtime.calls.hangup
        let referCall: (String, RealtimeCallReferParameters) async throws -> RealtimeCallObject = client.realtime.calls.refer
        let rejectCall: (String) async throws -> RealtimeCallObject = client.realtime.calls.reject
        let createSecret: (RealtimeClientSecretCreateParameters) async throws -> RealtimeClientSecretResponse = client.realtime.clientSecrets.create

        XCTAssertNotNil(createCall)
        XCTAssertNotNil(acceptCall)
        XCTAssertNotNil(hangupCall)
        XCTAssertNotNil(referCall)
        XCTAssertNotNil(rejectCall)
        XCTAssertNotNil(createSecret)

        let connection = await client.realtime.connect(options: .init(model: "gpt-realtime")).enter()
        let event = await connection.receive()
        XCTAssertEqual(event?.type, "connected")
        await connection.close()
    }
}
