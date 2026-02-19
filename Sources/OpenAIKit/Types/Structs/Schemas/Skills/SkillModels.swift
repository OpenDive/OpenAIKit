import Foundation

public struct SkillObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case name
        case description
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let name: String?
    public let description: String?
    public let createdAt: Int?
}

public struct SkillListResponse: Codable {
    public let object: String
    public let data: [SkillObject]
}

public struct SkillVersionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case version
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let version: String?
    public let createdAt: Int?
}

public struct SkillVersionListResponse: Codable {
    public let object: String
    public let data: [SkillVersionObject]
}
