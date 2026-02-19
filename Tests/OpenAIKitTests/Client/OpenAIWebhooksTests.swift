import CryptoKit
import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIWebhooksTests: XCTestCase {
    private struct TestWebhookEvent: Decodable {
        let type: String
    }

    private let secret = "whsec_test_123"

    private func makeClient() -> OpenAI {
        OpenAI(
            .init(
                apiKey: "test_key",
                organizationId: "org_test",
                webhookSecret: secret
            )
        )
    }

    private func signature(timestamp: String, payload: String) -> String {
        let message = "\(timestamp).\(payload)"
        let key = SymmetricKey(data: Data(secret.utf8))
        let digest = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        return Data(digest).map { String(format: "%02x", $0) }.joined()
    }

    func testVerifySignatureAcceptsValidHeaders() throws {
        let client = makeClient()
        let payload = #"{"type":"response.completed"}"#
        let timestamp = "1700000000"
        let sig = signature(timestamp: timestamp, payload: payload)
        let headers = [
            "OpenAI-Timestamp": timestamp,
            "OpenAI-Signature": "v1=\(sig)"
        ]

        XCTAssertNoThrow(try client.webhooks.verifySignature(payload: payload, headers: headers))
    }

    func testVerifySignatureRejectsInvalidSignature() {
        let client = makeClient()
        let payload = #"{"type":"response.completed"}"#
        let headers = [
            "OpenAI-Timestamp": "1700000000",
            "OpenAI-Signature": "v1=deadbeef"
        ]

        XCTAssertThrowsError(try client.webhooks.verifySignature(payload: payload, headers: headers))
    }

    func testUnwrapVerifiesAndDecodes() throws {
        let client = makeClient()
        let payload = #"{"type":"response.completed"}"#
        let timestamp = "1700000000"
        let sig = signature(timestamp: timestamp, payload: payload)
        let headers = [
            "webhook-timestamp": timestamp,
            "webhook-signature": sig
        ]

        let event = try client.webhooks.unwrap(payload: payload, headers: headers, as: TestWebhookEvent.self)
        XCTAssertEqual(event.type, "response.completed")
    }
}
