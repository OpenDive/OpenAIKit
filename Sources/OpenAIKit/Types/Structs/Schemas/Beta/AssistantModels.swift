import Foundation

public struct AssistantTool: Codable {
    public var type: String

    public init(type: String) {
        self.type = type
    }
}

public struct AssistantObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case name
        case description
        case model
        case instructions
        case tools
        case metadata
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let name: String?
    public let description: String?
    public let model: String
    public let instructions: String?
    public let tools: [AssistantTool]?
    public let metadata: [String: String]?
}

public struct AssistantListResponse: Codable {
    public let object: String
    public let data: [AssistantObject]
}

public struct ThreadObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case metadata
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let metadata: [String: String]?
}

public struct ThreadListResponse: Codable {
    public let object: String
    public let data: [ThreadObject]
}

public struct ThreadRunObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case status
        case model
        case assistantId = "assistant_id"
        case threadId = "thread_id"
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let status: String?
    public let model: String?
    public let assistantId: String?
    public let threadId: String?
}

public struct ThreadRunListResponse: Codable {
    public let object: String
    public let data: [ThreadRunObject]
}

public struct ThreadRunStepObject: Codable {
    public let id: String
    public let object: String?
    public let type: String?
    public let status: String?
}

public struct ThreadRunStepListResponse: Codable {
    public let object: String
    public let data: [ThreadRunStepObject]
}
