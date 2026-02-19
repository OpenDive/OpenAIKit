import Foundation

public struct RealtimeConnectionOptions: Sendable {
    public var model: String?
    public var callID: String?

    public init(model: String? = nil, callID: String? = nil) {
        self.model = model
        self.callID = callID
    }
}

public struct RealtimeConnectionEvent: Sendable {
    public let type: String
    public let payload: String?

    public init(type: String, payload: String? = nil) {
        self.type = type
        self.payload = payload
    }
}

public actor RealtimeConnection {
    private var isClosed = false
    private let options: RealtimeConnectionOptions

    init(options: RealtimeConnectionOptions) {
        self.options = options
    }

    public func receive() -> RealtimeConnectionEvent? {
        guard !isClosed else { return nil }
        return RealtimeConnectionEvent(type: "connected", payload: options.model)
    }

    public func send(_ event: RealtimeConnectionEvent) {
        _ = event
    }

    public func close() {
        isClosed = true
    }
}

public struct RealtimeConnectionManager {
    private let options: RealtimeConnectionOptions

    init(options: RealtimeConnectionOptions) {
        self.options = options
    }

    public func enter() async -> RealtimeConnection {
        RealtimeConnection(options: options)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension RealtimeResource {
    func connect(options: RealtimeConnectionOptions = .init()) -> RealtimeConnectionManager {
        RealtimeConnectionManager(options: options)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension RealtimeCallsResource {
    func create(parameters: RealtimeCallCreateParameters = .init()) async throws -> RealtimeCallObject {
        let url = try client.getServerUrl(path: "/realtime/calls")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func accept(callID: String) async throws -> RealtimeCallObject {
        let url = try client.getServerUrl(path: "/realtime/calls/\(callID)/accept")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }

    func hangup(callID: String) async throws -> RealtimeCallObject {
        let url = try client.getServerUrl(path: "/realtime/calls/\(callID)/hangup")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }

    func refer(callID: String, parameters: RealtimeCallReferParameters) async throws -> RealtimeCallObject {
        let url = try client.getServerUrl(path: "/realtime/calls/\(callID)/refer")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func reject(callID: String) async throws -> RealtimeCallObject {
        let url = try client.getServerUrl(path: "/realtime/calls/\(callID)/reject")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension RealtimeClientSecretsResource {
    func create(parameters: RealtimeClientSecretCreateParameters = .init()) async throws -> RealtimeClientSecretResponse {
        let url = try client.getServerUrl(path: "/realtime/client_secrets")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }
}
