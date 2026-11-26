// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// The protocol every generated model conforms to.
///
/// It supplies `Equatable` and `Hashable` once, for all ~2,300 generated types, instead of a
/// synthesized `==` and `hash(into:)` per type, which kept megabytes of code in every app.
/// Two values are equal when their canonical JSON encodings are equal, which for API models is
/// the same as field-by-field equality: `nil` and an omitted field compare equal, as they do on the wire.
///
/// Comparing or hashing encodes the value, so it costs more than synthesized equality. Avoid
/// comparing large values in hot loops; compare their `id` instead.
public protocol OpenAIModel: Codable, Hashable, Sendable {}

public extension OpenAIModel {
    static func == (lhs: Self, rhs: Self) -> Bool {
        OpenAIModelCanonicalJSON.equal(lhs, rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(OpenAIModelCanonicalJSON.encode(self))
    }
}

// Never specialized or inlined, so the ~1,500 `==` and `hash(into:)` witnesses stay small calls
// into one shared function instead of each carrying its own copy (about 200 KB in an app).
enum OpenAIModelCanonicalJSON {
    @inline(never)
    @_semantics("optimize.sil.specialize.generic.never")
    static func encode<Value: Encodable>(_ value: Value) -> Data? {
        try? JSONEncoder.openAI.encode(value)
    }

    @inline(never)
    @_semantics("optimize.sil.specialize.generic.never")
    static func equal<Value: Encodable>(_ lhs: Value, _ rhs: Value) -> Bool {
        guard let left = encode(lhs), let right = encode(rhs) else { return false }
        return left == right
    }
}
