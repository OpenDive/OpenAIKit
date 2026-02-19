import Foundation

public struct EvalCreateParameters: Encodable {
    public var name: String
    public var metadata: [String: String]?

    public init(name: String, metadata: [String: String]? = nil) {
        self.name = name
        self.metadata = metadata
    }
}

public struct EvalRunCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case input
        case model
        case metadata
    }

    public var input: String
    public var model: String?
    public var metadata: [String: String]?

    public init(input: String, model: String? = nil, metadata: [String: String]? = nil) {
        self.input = input
        self.model = model
        self.metadata = metadata
    }
}
