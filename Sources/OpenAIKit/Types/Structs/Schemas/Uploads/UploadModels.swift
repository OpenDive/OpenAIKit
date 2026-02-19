import Foundation

public struct UploadObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case bytes
        case filename
        case status
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let bytes: Int?
    public let filename: String?
    public let status: String?
    public let createdAt: Int?
}

public struct UploadPartObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case uploadID = "upload_id"
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let uploadID: String?
}
