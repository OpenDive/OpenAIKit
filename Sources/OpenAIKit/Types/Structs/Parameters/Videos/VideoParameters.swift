import Foundation

public struct VideoCreateParameters: Encodable {
    public var model: String
    public var prompt: String

    public init(model: String, prompt: String) {
        self.model = model
        self.prompt = prompt
    }
}
