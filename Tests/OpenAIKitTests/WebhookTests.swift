// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Testing
import OpenAIKit
@testable import OpenAIKitCore

@Suite("Webhooks")
struct WebhookTests {
    let secret = "whsec_" + Data("super-secret-signing-key".utf8).base64EncodedString()
    let payload = #"{"id":"evt_1","object":"event","created_at":1750000000,"type":"response.completed","data":{"id":"resp_1"}}"#
    let timestamp = 1_750_000_000

    func headers(signature: String? = nil, timestamp: Int? = nil) -> [String: String] {
        let ts = timestamp ?? self.timestamp
        let key = Data(base64Encoded: String(secret.dropFirst(6)))!
        let expected = WebhookCrypto.hmacSHA256(key: key, message: Data("evt_1.\(ts).\(payload)".utf8)).base64EncodedString()
        return ["Webhook-Id": "evt_1", "webhook-timestamp": String(ts), "webhook-signature": signature ?? "v1,bogus v1,\(expected)"]
    }

    var client: OpenAI { OpenAI(Configuration(apiKey: "sk", webhookSecret: secret)) }
    var now: Date { Date(timeIntervalSince1970: TimeInterval(timestamp + 10)) }

    @Test func acceptsAValidSignature() throws {
        try client.webhooks.verifySignature(payload: Data(payload.utf8), headers: headers(), now: now)
    }

    @Test func rejectsATamperedPayload() {
        #expect(throws: OpenAIWebhookError.invalidSignature) {
            try client.webhooks.verifySignature(payload: Data((payload + " ").utf8), headers: headers(), now: now)
        }
    }

    @Test func rejectsOldAndFutureTimestamps() {
        #expect(throws: OpenAIWebhookError.timestampTooOld) {
            try client.webhooks.verifySignature(payload: Data(payload.utf8), headers: headers(), now: now.addingTimeInterval(1_000))
        }
        #expect(throws: OpenAIWebhookError.timestampTooNew) {
            try client.webhooks.verifySignature(payload: Data(payload.utf8), headers: headers(), now: now.addingTimeInterval(-1_000))
        }
    }

    @Test func requiresHeadersAndASecret() {
        #expect(throws: OpenAIWebhookError.missingHeader("webhook-id")) {
            try client.webhooks.verifySignature(payload: Data(payload.utf8), headers: ["webhook-signature": "x", "webhook-timestamp": "1"], now: now)
        }
        #expect(throws: OpenAIWebhookError.missingSecret) {
            try OpenAI(apiKey: "sk").webhooks.verifySignature(payload: Data(payload.utf8), headers: headers(), now: now)
        }
    }

    @Test func unwrapsTypedEvents() throws {
        let fresh = Int(Date().timeIntervalSince1970)
        let event = try client.webhooks.unwrap(payload: Data(payload.utf8), headers: headers(timestamp: fresh))
        guard case .responseCompleted(let completed) = event else {
            Issue.record("Expected .responseCompleted, got \(event)")
            return
        }
        #expect(completed.data.id == "resp_1")
    }

    @Test func portableSHA256MatchesKnownVectors() {
        func hex(_ bytes: [UInt8]) -> String { bytes.map { String(format: "%02x", $0) }.joined() }
        #expect(hex(PortableSHA256.hash(Array("abc".utf8))) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(hex(PortableSHA256.hash([])) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        // RFC 4231 test case 2.
        let mac = PortableSHA256.hmac(key: Array("Jefe".utf8), message: Array("what do ya want for nothing?".utf8))
        #expect(hex([UInt8](mac)) == "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843")
        // A key longer than the block size is hashed first.
        let longKey = [UInt8](repeating: 0xaa, count: 131)
        let message = Array("Test Using Larger Than Block-Size Key - Hash Key First".utf8)
        #expect(hex([UInt8](PortableSHA256.hmac(key: longKey, message: message))) == "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54")
        #expect(PortableSHA256.hmac(key: longKey, message: message) == WebhookCrypto.hmacSHA256(key: Data(longKey), message: Data(message)))
    }
}
