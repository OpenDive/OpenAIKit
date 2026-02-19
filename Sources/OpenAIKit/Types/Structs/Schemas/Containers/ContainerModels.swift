import Foundation

public struct ContainerObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case name
        case status
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let name: String?
    public let status: String?
    public let createdAt: Int?
}

public struct ContainerListResponse: Codable {
    public let object: String
    public let data: [ContainerObject]
}

public struct ContainerFileObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case filename
        case bytes
        case createdAt = "created_at"
    }

    public let id: String
    public let object: String?
    public let filename: String?
    public let bytes: Int?
    public let createdAt: Int?
}

public struct ContainerFileListResponse: Codable {
    public let object: String
    public let data: [ContainerFileObject]
}
