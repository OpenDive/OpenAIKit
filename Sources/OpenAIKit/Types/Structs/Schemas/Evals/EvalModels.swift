import Foundation

public struct EvalObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case name
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let name: String?
    public let createdAt: Int?
}

public struct EvalListResponse: Codable {
    public let object: String
    public let data: [EvalObject]
}

public struct EvalRunObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case status
        case evalID = "eval_id"
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let status: String?
    public let evalID: String?
    public let createdAt: Int?
}

public struct EvalRunListResponse: Codable {
    public let object: String
    public let data: [EvalRunObject]
}

public struct EvalRunOutputItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case type
    }

    public let id: String
    public let object: String?
    public let type: String?
}

public struct EvalRunOutputItemListResponse: Codable {
    public let object: String
    public let data: [EvalRunOutputItem]
}
