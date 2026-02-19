import Foundation

public struct ConversationCreateParameters: Encodable {
    public var metadata: [String: String]?

    public init(metadata: [String: String]? = nil) {
        self.metadata = metadata
    }
}

public struct ConversationItemCreateParameters: Encodable {
    public var type: String
    public var role: String?
    public var content: String

    public init(type: String = "message", role: String? = nil, content: String) {
        self.type = type
        self.role = role
        self.content = content
    }
}
