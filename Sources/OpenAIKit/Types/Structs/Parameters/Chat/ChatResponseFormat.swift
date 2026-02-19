import Foundation

/// Response format options for chat completions.
public struct ChatResponseFormat: Codable {
    public enum Kind: String, Codable {
        case text
        case jsonObject = "json_object"
        case jsonSchema = "json_schema"
    }

    public var type: Kind

    public init(type: Kind) {
        self.type = type
    }
}
