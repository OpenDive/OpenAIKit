import Foundation

public struct ConversationObject: Codable {
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

public struct ConversationListResponse: Codable {
    public let object: String
    public let data: [ConversationObject]
}

public struct ConversationItemObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case type
        case role
        case content
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let type: String?
    public let role: String?
    public let content: String?
    public let createdAt: Int?
}

public struct ConversationItemListResponse: Codable {
    public let object: String
    public let data: [ConversationItemObject]
}
