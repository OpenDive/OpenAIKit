import CryptoKit
import Foundation

public enum OpenAIWebhookError: Error {
    case missingWebhookSecret
    case missingTimestamp
    case missingSignature
    case invalidSignature
    case invalidPayload
}

private extension String {
    var openAIWebhookHexData: Data? {
        let clean = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard clean.count % 2 == 0 else { return nil }
        var data = Data()
        data.reserveCapacity(clean.count / 2)

        var index = clean.startIndex
        while index < clean.endIndex {
            let next = clean.index(index, offsetBy: 2)
            let byteString = clean[index..<next]
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            index = next
        }

        return data
    }
}

private extension Dictionary where Key == String, Value == String {
    func openAIWebhookValue(for candidates: [String]) -> String? {
        var lowercaseMap: [String: String] = [:]
        for (key, value) in self {
            lowercaseMap[key.lowercased()] = value
        }

        for candidate in candidates {
            if let value = lowercaseMap[candidate.lowercased()] {
                return value
            }
        }

        return nil
    }
}

public extension WebhooksResource {
    func verifySignature(
        payload: String,
        headers: [String: String],
        secret: String? = nil
    ) throws {
        let resolvedSecret = secret ?? client.configuration.webhookSecret
        guard let webhookSecret = resolvedSecret, !webhookSecret.isEmpty else {
            throw OpenAIWebhookError.missingWebhookSecret
        }

        guard let timestamp = headers.openAIWebhookValue(for: ["openai-timestamp", "webhook-timestamp"]) else {
            throw OpenAIWebhookError.missingTimestamp
        }
        guard let signatureHeader = headers.openAIWebhookValue(for: ["openai-signature", "webhook-signature"]) else {
            throw OpenAIWebhookError.missingSignature
        }

        let signatureValue: String
        if let valueRange = signatureHeader.range(of: "v1=") {
            signatureValue = String(signatureHeader[valueRange.upperBound...]).split(separator: ",").first.map(String.init) ?? ""
        } else {
            signatureValue = signatureHeader
        }

        guard let providedSignature = signatureValue.openAIWebhookHexData else {
            throw OpenAIWebhookError.invalidSignature
        }

        let message = "\(timestamp).\(payload)"
        let key = SymmetricKey(data: Data(webhookSecret.utf8))
        let digest = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        let expected = Data(digest)

        guard expected == providedSignature else {
            throw OpenAIWebhookError.invalidSignature
        }
    }

    func unwrap<Event: Decodable>(
        payload: String,
        headers: [String: String],
        as type: Event.Type = Event.self,
        secret: String? = nil
    ) throws -> Event {
        try verifySignature(payload: payload, headers: headers, secret: secret)

        guard let data = payload.data(using: .utf8) else {
            throw OpenAIWebhookError.invalidPayload
        }

        return try JSONDecoder().decode(type, from: data)
    }

}
