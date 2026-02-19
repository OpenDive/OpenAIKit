import Foundation

public struct RealtimeCallCreateParameters: Encodable {
    public var model: String?
    public var metadata: [String: String]?

    public init(model: String? = nil, metadata: [String: String]? = nil) {
        self.model = model
        self.metadata = metadata
    }
}

public struct RealtimeCallReferParameters: Encodable {
    public var target: String
    public var reason: String?

    public init(target: String, reason: String? = nil) {
        self.target = target
        self.reason = reason
    }
}

public struct RealtimeClientSecretCreateParameters: Encodable {
    public var model: String?
    public var voice: String?

    public init(model: String? = nil, voice: String? = nil) {
        self.model = model
        self.voice = voice
    }
}
