import Foundation

public struct VectorStoreCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case fileIDs = "file_ids"
        case metadata
    }

    public var name: String?
    public var fileIDs: [String]?
    public var metadata: [String: String]?

    public init(name: String? = nil, fileIDs: [String]? = nil, metadata: [String: String]? = nil) {
        self.name = name
        self.fileIDs = fileIDs
        self.metadata = metadata
    }
}

public struct VectorStoreUpdateParameters: Encodable {
    public var name: String?
    public var metadata: [String: String]?

    public init(name: String? = nil, metadata: [String: String]? = nil) {
        self.name = name
        self.metadata = metadata
    }
}

public struct VectorStoreFileCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
    }

    public var fileID: String

    public init(fileID: String) {
        self.fileID = fileID
    }
}

public struct VectorStoreFileBatchCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case fileIDs = "file_ids"
    }

    public var fileIDs: [String]

    public init(fileIDs: [String]) {
        self.fileIDs = fileIDs
    }
}
