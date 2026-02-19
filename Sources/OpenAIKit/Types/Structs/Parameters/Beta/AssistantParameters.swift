import Foundation

public struct AssistantCreateParameters: Encodable {
    public var model: String
    public var name: String?
    public var description: String?
    public var instructions: String?
    public var tools: [AssistantTool]?
    public var metadata: [String: String]?

    public init(
        model: String,
        name: String? = nil,
        description: String? = nil,
        instructions: String? = nil,
        tools: [AssistantTool]? = nil,
        metadata: [String: String]? = nil
    ) {
        self.model = model
        self.name = name
        self.description = description
        self.instructions = instructions
        self.tools = tools
        self.metadata = metadata
    }
}

public struct AssistantUpdateParameters: Encodable {
    public var model: String?
    public var name: String?
    public var description: String?
    public var instructions: String?
    public var tools: [AssistantTool]?
    public var metadata: [String: String]?

    public init(
        model: String? = nil,
        name: String? = nil,
        description: String? = nil,
        instructions: String? = nil,
        tools: [AssistantTool]? = nil,
        metadata: [String: String]? = nil
    ) {
        self.model = model
        self.name = name
        self.description = description
        self.instructions = instructions
        self.tools = tools
        self.metadata = metadata
    }
}

public struct ThreadCreateParameters: Encodable {
    public var metadata: [String: String]?

    public init(metadata: [String: String]? = nil) {
        self.metadata = metadata
    }
}

public struct ThreadUpdateParameters: Encodable {
    public var metadata: [String: String]?

    public init(metadata: [String: String]? = nil) {
        self.metadata = metadata
    }
}

public struct ThreadRunCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case assistantId = "assistant_id"
        case model
        case instructions
        case metadata
    }

    public var assistantId: String
    public var model: String?
    public var instructions: String?
    public var metadata: [String: String]?

    public init(
        assistantId: String,
        model: String? = nil,
        instructions: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.assistantId = assistantId
        self.model = model
        self.instructions = instructions
        self.metadata = metadata
    }
}
