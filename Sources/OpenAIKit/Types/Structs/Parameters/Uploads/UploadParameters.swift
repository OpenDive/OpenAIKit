import Foundation

public struct UploadCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case bytes
        case filename
        case purpose
        case mimeType = "mime_type"
    }

    public var bytes: Int
    public var filename: String
    public var purpose: String
    public var mimeType: String?

    public init(bytes: Int, filename: String, purpose: String, mimeType: String? = nil) {
        self.bytes = bytes
        self.filename = filename
        self.purpose = purpose
        self.mimeType = mimeType
    }
}

public struct UploadCompleteParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case partIDs = "part_ids"
    }

    public var partIDs: [String]

    public init(partIDs: [String]) {
        self.partIDs = partIDs
    }
}

public struct UploadPartCreateParameters: Encodable {
    public var data: String

    public init(data: String) {
        self.data = data
    }
}
