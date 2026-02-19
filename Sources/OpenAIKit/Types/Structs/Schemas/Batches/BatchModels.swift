import Foundation

public struct BatchObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case endpoint
        case inputFileID = "input_file_id"
        case completionWindow = "completion_window"
        case status
        case createdAt = "created_at"
        case outputFileID = "output_file_id"
        case errorFileID = "error_file_id"
    }

    public let id: String
    public let object: String?
    public let endpoint: String?
    public let inputFileID: String?
    public let completionWindow: String?
    public let status: String?
    public let createdAt: Int?
    public let outputFileID: String?
    public let errorFileID: String?
}

public struct BatchListResponse: Codable {
    public let object: String
    public let data: [BatchObject]
}
