import Foundation

public struct ResponseCreateParameters: Encodable {
    public var model: String
    public var input: String
    public var instructions: String?
    public var stream: Bool?
    public var metadata: [String: String]?

    public init(
        model: String,
        input: String,
        instructions: String? = nil,
        stream: Bool? = nil,
        metadata: [String: String]? = nil
    ) {
        self.model = model
        self.input = input
        self.instructions = instructions
        self.stream = stream
        self.metadata = metadata
    }
}

public struct ResponseInputTokensParameters: Encodable {
    public var model: String
    public var input: String

    public init(model: String, input: String) {
        self.model = model
        self.input = input
    }
}
