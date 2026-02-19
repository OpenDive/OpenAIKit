import Foundation

/// Tool definition for modern chat completions.
public struct ChatTool: Codable {
    /// Tool type. Defaults to `function`.
    public var type: String

    /// Function tool payload.
    public var function: Function

    public init(type: String = "function", function: Function) {
        self.type = type
        self.function = function
    }
}
