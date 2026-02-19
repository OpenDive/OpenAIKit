import Foundation

public struct VectorStoreObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case name
        case createdAt = "created_at"
        case status
        case metadata
    }

    public let id: String
    public let object: String?
    public let name: String?
    public let createdAt: Int?
    public let status: String?
    public let metadata: [String: String]?
}

public struct VectorStoreListResponse: Codable {
    public let object: String
    public let data: [VectorStoreObject]
}

public struct VectorStoreFileObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case status
        case vectorStoreId = "vector_store_id"
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let status: String?
    public let vectorStoreId: String?
}

public struct VectorStoreFileListResponse: Codable {
    public let object: String
    public let data: [VectorStoreFileObject]
}

public struct VectorStoreFileBatchObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case status
        case vectorStoreId = "vector_store_id"
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let status: String?
    public let vectorStoreId: String?
}

public struct VectorStoreFileBatchListResponse: Codable {
    public let object: String
    public let data: [VectorStoreFileBatchObject]
}
