// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Why a webhook failed verification.
public enum OpenAIWebhookError: Error, Sendable, Equatable {
    /// No secret was passed and `Configuration.webhookSecret` is not set, or the secret is empty.
    case missingSecret
    /// A required header is missing: `webhook-id`, `webhook-timestamp` or `webhook-signature`.
    case missingHeader(String)
    /// `webhook-timestamp` is not a Unix time in seconds.
    case invalidTimestamp
    /// The timestamp is older than the tolerance allows. This protects against replayed events.
    case timestampTooOld
    /// The timestamp is further in the future than the tolerance allows.
    case timestampTooNew
    /// No signature in `webhook-signature` matches the payload.
    case invalidSignature
}

public extension WebhooksResource {
    /// Verifies that a webhook request came from OpenAI.
    ///
    /// OpenAI signs webhooks with the [Standard Webhooks](https://www.standardwebhooks.com) scheme:
    /// an HMAC-SHA256 over `"{webhook-id}.{webhook-timestamp}.{body}"`.
    ///
    /// - Parameters:
    ///   - payload: The raw request body, exactly as received.
    ///   - headers: The request headers. Names are matched without regard to case.
    ///   - secret: The endpoint's signing secret (`whsec_...`). Defaults to `Configuration.webhookSecret`.
    ///   - tolerance: Largest accepted clock difference, in seconds. Defaults to 5 minutes.
    ///   - now: The current time. Override it in tests.
    func verifySignature(
        payload: Data,
        headers: [String: String],
        secret: String? = nil,
        tolerance: TimeInterval = 300,
        now: Date = Date()
    ) throws {
        guard let secret = secret ?? client.configuration.webhookSecret, !secret.isEmpty else {
            throw OpenAIWebhookError.missingSecret
        }
        func header(_ name: String) throws -> String {
            guard let value = headers.first(where: { $0.key.lowercased() == name })?.value else {
                throw OpenAIWebhookError.missingHeader(name)
            }
            return value
        }
        let signatureHeader = try header("webhook-signature")
        let timestamp = try header("webhook-timestamp")
        let id = try header("webhook-id")

        guard let seconds = Int(timestamp) else { throw OpenAIWebhookError.invalidTimestamp }
        let current = Int(now.timeIntervalSince1970)
        if current - seconds > Int(tolerance) { throw OpenAIWebhookError.timestampTooOld }
        if seconds > current + Int(tolerance) { throw OpenAIWebhookError.timestampTooNew }

        let key: Data
        if secret.hasPrefix("whsec_") {
            guard let decoded = Data(base64Encoded: String(secret.dropFirst(6))) else { throw OpenAIWebhookError.missingSecret }
            key = decoded
        } else {
            key = Data(secret.utf8)
        }
        guard !key.isEmpty else { throw OpenAIWebhookError.missingSecret }

        var signed = Data("\(id).\(timestamp).".utf8)
        signed.append(payload)
        let expected = WebhookCrypto.hmacSHA256(key: key, message: signed)

        let candidates = signatureHeader.split(separator: " ").map { part -> String in
            part.hasPrefix("v1,") ? String(part.dropFirst(3)) : String(part)
        }
        for candidate in candidates {
            if let provided = Data(base64Encoded: candidate), WebhookCrypto.constantTimeEqual(provided, expected) {
                return
            }
        }
        throw OpenAIWebhookError.invalidSignature
    }

    /// Verifies a webhook request and decodes its event.
    ///
    /// ```swift
    /// let event = try client.webhooks.unwrap(payload: body, headers: headers)
    /// if case .responseCompleted(let completed) = event {
    ///     print(completed.data.id)
    /// }
    /// ```
    func unwrap(
        payload: Data,
        headers: [String: String],
        secret: String? = nil,
        tolerance: TimeInterval = 300
    ) throws -> WebhookEvent {
        try unwrap(payload: payload, headers: headers, as: WebhookEvent.self, secret: secret, tolerance: tolerance)
    }

    /// Verifies a webhook request and decodes it as a specific type.
    func unwrap<Event: Decodable>(
        payload: Data,
        headers: [String: String],
        as type: Event.Type,
        secret: String? = nil,
        tolerance: TimeInterval = 300
    ) throws -> Event {
        try verifySignature(payload: payload, headers: headers, secret: secret, tolerance: tolerance)
        return try JSONDecoder().decode(Event.self, from: payload)
    }
}

enum WebhookCrypto {
    static func hmacSHA256(key: Data, message: Data) -> Data {
        #if canImport(CryptoKit)
        let mac = HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: key))
        return Data(mac)
        #else
        return PortableSHA256.hmac(key: [UInt8](key), message: [UInt8](message))
        #endif
    }

    static func constantTimeEqual(_ lhs: Data, _ rhs: Data) -> Bool {
        guard lhs.count == rhs.count else { return false }
        var difference: UInt8 = 0
        for (a, b) in zip(lhs, rhs) { difference |= a ^ b }
        return difference == 0
    }
}

/// SHA-256 and HMAC for platforms without CryptoKit, such as Linux.
enum PortableSHA256 {
    private static let k: [UInt32] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ]

    static func hash(_ message: [UInt8]) -> [UInt8] {
        var h: [UInt32] = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]
        var bytes = message
        let bitLength = UInt64(message.count) * 8
        bytes.append(0x80)
        while bytes.count % 64 != 56 { bytes.append(0) }
        for shift in stride(from: 56, through: 0, by: -8) { bytes.append(UInt8((bitLength >> UInt64(shift)) & 0xff)) }
        var w = [UInt32](repeating: 0, count: 64)
        for chunk in stride(from: 0, to: bytes.count, by: 64) {
            for i in 0..<16 {
                let j = chunk + i * 4
                w[i] = UInt32(bytes[j]) << 24 | UInt32(bytes[j + 1]) << 16 | UInt32(bytes[j + 2]) << 8 | UInt32(bytes[j + 3])
            }
            for i in 16..<64 {
                let s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3)
                let s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10)
                w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
            }
            var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4], f = h[5], g = h[6], hh = h[7]
            for i in 0..<64 {
                let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
                let ch = (e & f) ^ (~e & g)
                let t1 = hh &+ s1 &+ ch &+ k[i] &+ w[i]
                let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
                let maj = (a & b) ^ (a & c) ^ (b & c)
                let t2 = s0 &+ maj
                hh = g; g = f; f = e; e = d &+ t1; d = c; c = b; b = a; a = t1 &+ t2
            }
            h[0] = h[0] &+ a; h[1] = h[1] &+ b; h[2] = h[2] &+ c; h[3] = h[3] &+ d
            h[4] = h[4] &+ e; h[5] = h[5] &+ f; h[6] = h[6] &+ g; h[7] = h[7] &+ hh
        }
        return h.flatMap { value in [24, 16, 8, 0].map { UInt8((value >> UInt32($0)) & 0xff) } }
    }

    static func hmac(key: [UInt8], message: [UInt8]) -> Data {
        var key = key.count > 64 ? hash(key) : key
        key += [UInt8](repeating: 0, count: 64 - key.count)
        let inner = hash(key.map { $0 ^ 0x36 } + message)
        return Data(hash(key.map { $0 ^ 0x5c } + inner))
    }

    private static func rotr(_ value: UInt32, _ count: UInt32) -> UInt32 {
        (value >> count) | (value << (32 - count))
    }
}
