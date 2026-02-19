import Foundation

public struct VideoObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case status
        case model
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let status: String?
    public let model: String?
    public let createdAt: Int?
}

public struct VideoListResponse: Codable {
    public let object: String
    public let data: [VideoObject]
}
