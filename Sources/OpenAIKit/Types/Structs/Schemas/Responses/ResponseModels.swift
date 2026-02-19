import Foundation

public struct ResponseObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case model
        case status
        case outputText = "output_text"
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let model: String?
    public let status: String?
    public let outputText: String?
    public let createdAt: Int?
}

public struct ResponseInputItem: Codable {
    public let id: String?
    public let type: String?
    public let role: String?
    public let content: String?
}

public struct ResponseInputItemListResponse: Codable {
    public let object: String
    public let data: [ResponseInputItem]
}

public struct ResponseInputTokenCount: Codable {
    enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
    }

    public let totalTokens: Int
}
