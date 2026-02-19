import Foundation

public struct BatchCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case inputFileID = "input_file_id"
        case endpoint
        case completionWindow = "completion_window"
        case metadata
    }

    public var inputFileID: String
    public var endpoint: String
    public var completionWindow: String
    public var metadata: [String: String]?

    public init(
        inputFileID: String,
        endpoint: String,
        completionWindow: String = "24h",
        metadata: [String: String]? = nil
    ) {
        self.inputFileID = inputFileID
        self.endpoint = endpoint
        self.completionWindow = completionWindow
        self.metadata = metadata
    }
}
