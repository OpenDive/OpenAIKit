import Foundation

public struct RealtimeCallObject: Codable {
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

public struct RealtimeClientSecretObject: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case expiresAt = "expires_at"
    }

    public let value: String
    public let expiresAt: Int?
}

public struct RealtimeClientSecretResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
    }

    public let clientSecret: RealtimeClientSecretObject
}
