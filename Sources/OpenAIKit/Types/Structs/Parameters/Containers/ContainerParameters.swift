import Foundation

public struct ContainerCreateParameters: Encodable {
    public var name: String
    public var metadata: [String: String]?

    public init(name: String, metadata: [String: String]? = nil) {
        self.name = name
        self.metadata = metadata
    }
}

public struct ContainerFileCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
    }

    public var fileID: String

    public init(fileID: String) {
        self.fileID = fileID
    }
}
