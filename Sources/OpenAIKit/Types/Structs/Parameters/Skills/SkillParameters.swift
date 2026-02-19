import Foundation

public struct SkillCreateParameters: Encodable {
    public var name: String
    public var description: String?
    public var metadata: [String: String]?

    public init(name: String, description: String? = nil, metadata: [String: String]? = nil) {
        self.name = name
        self.description = description
        self.metadata = metadata
    }
}

public struct SkillUpdateParameters: Encodable {
    public var name: String?
    public var description: String?
    public var metadata: [String: String]?

    public init(name: String? = nil, description: String? = nil, metadata: [String: String]? = nil) {
        self.name = name
        self.description = description
        self.metadata = metadata
    }
}

public struct SkillContentUpdateParameters: Encodable {
    public var content: String

    public init(content: String) {
        self.content = content
    }
}
