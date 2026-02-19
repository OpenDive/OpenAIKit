import Foundation

/// Request behavior options used by OpenAIKit transport calls.
public struct OpenAIRequestOptions: Sendable {
    /// Per-request timeout interval in seconds.
    public let timeoutInterval: TimeInterval

    /// Number of retries to apply for transient transport failures.
    public let maxRetries: Int

    /// Additional HTTP headers merged into each request.
    public let additionalHeaders: [String: String]

    public init(
        timeoutInterval: TimeInterval = 600,
        maxRetries: Int = 2,
        additionalHeaders: [String: String] = [:]
    ) {
        self.timeoutInterval = timeoutInterval
        self.maxRetries = max(maxRetries, 0)
        self.additionalHeaders = additionalHeaders
    }
}
