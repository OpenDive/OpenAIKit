// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// Any JSON value.
///
/// Generated models use `JSONValue` where the OpenAI spec allows arbitrary JSON, for example
/// function-call arguments, JSON schemas and metadata, and as the payload of `.unknown` cases.
public enum JSONValue: Codable, Hashable, Sendable {
    case null
    case bool(Bool)
    case integer(Int)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not a JSON value")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    /// Encodes any `Encodable` value into a `JSONValue`.
    public init<T: Encodable>(encoding value: T) throws {
        let data = try JSONEncoder.openAI.encode(value)
        self = try JSONDecoder().decode(JSONValue.self, from: data)
    }

    /// Decodes this value into a concrete `Decodable` type.
    public func decode<T: Decodable>(as type: T.Type = T.self) throws -> T {
        let data = try JSONEncoder.openAI.encode(self)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Parses JSON text such as tool-call arguments.
    public init(parsing text: String) throws {
        self = try JSONDecoder().decode(JSONValue.self, from: Data(text.utf8))
    }

    /// Compact JSON text for this value.
    public var jsonString: String {
        (try? String(decoding: JSONEncoder.openAI.encode(self), as: UTF8.self)) ?? "null"
    }

    public subscript(key: String) -> JSONValue? {
        if case .object(let object) = self { return object[key] }
        return nil
    }

    public subscript(index: Int) -> JSONValue? {
        if case .array(let array) = self, array.indices.contains(index) { return array[index] }
        return nil
    }

    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    public var intValue: Int? {
        switch self {
        case .integer(let value): return value
        case .number(let value) where value.rounded() == value: return Int(exactly: value)
        default: return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .integer(let value): return Double(value)
        case .number(let value): return value
        default: return nil
        }
    }

    public var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }

    public var arrayValue: [JSONValue]? {
        if case .array(let value) = self { return value }
        return nil
    }

    public var objectValue: [String: JSONValue]? {
        if case .object(let value) = self { return value }
        return nil
    }

    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }
}

/// A JSON object with arbitrary keys.
public typealias JSONObject = [String: JSONValue]

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) { self = .null }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .bool(value) }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .integer(value) }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .number(value) }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(elements, uniquingKeysWith: { _, last in last }))
    }
}

extension JSONValue: CustomStringConvertible {
    public var description: String { jsonString }
}

/// A coding key built from any string. Generated models use it for every property, instead of
/// a `CodingKeys` enum per type, which kept megabytes of code in every app.
public struct OpenAIDynamicCodingKey: CodingKey, Hashable, Sendable, ExpressibleByStringLiteral {
    public var stringValue: String
    public var intValue: Int?

    public init(_ string: String) {
        self.stringValue = string
        self.intValue = nil
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// A string-backed enum that also accepts values it does not list.
///
/// OpenAI adds models, voices, event types and other enum values often. Every generated enum
/// conforms to this protocol, so a new value decodes instead of failing, and you can pass a
/// value before OpenAIKit lists it: `let model: ChatModel = "gpt-next"`.
public protocol OpenAIStringEnum: RawRepresentable, Codable, Hashable, Sendable,
    ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible where RawValue == String {
    init(rawValue: String)
    /// The values listed in the OpenAPI spec this version was generated from.
    static var knownValues: [Self] { get }
}

public extension OpenAIStringEnum {
    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    init(from decoder: any Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var description: String { rawValue }

    /// Whether the spec this version was generated from lists this value.
    var isKnown: Bool { Self.knownValues.contains(self) }
}

extension JSONEncoder {
    /// The encoder OpenAIKit uses for request bodies.
    static var openAI: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}
