// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A typed WebSocket connection to the OpenAI API, used by the Realtime and Responses WebSocket modes.
///
/// ```swift
/// let connection = try client.responses.connect()
/// try await connection.send(.sessionUpdate(...))
/// for try await event in connection.events {
///     print(event)
/// }
/// ```
public final class OpenAIWebSocket<Outgoing: Encodable & Sendable, Incoming: Decodable & Sendable>: Sendable {
    /// Events from the server, in order. The stream ends when the socket closes.
    public let events: AsyncThrowingStream<Incoming, any Error>

    private let task: URLSessionWebSocketTask
    private let session: URLSession

    init(request: URLRequest) {
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: request)
        self.session = session
        self.task = task
        self.events = AsyncThrowingStream { continuation in
            let reader = Task {
                let decoder = JSONDecoder()
                while !Task.isCancelled {
                    do {
                        let message = try await task.receive()
                        let data: Data
                        switch message {
                        case .string(let text): data = Data(text.utf8)
                        case .data(let bytes): data = bytes
                        @unknown default: continue
                        }
                        do {
                            continuation.yield(try decoder.decode(Incoming.self, from: data))
                        } catch {
                            continuation.finish(throwing: OpenAIError.decoding(type: String(describing: Incoming.self), underlying: error, body: data))
                            return
                        }
                    } catch {
                        if task.closeCode != .invalid {
                            continuation.finish()
                        } else {
                            continuation.finish(throwing: OpenAIError.connection(error))
                        }
                        return
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in reader.cancel() }
        }
        task.resume()
    }

    /// Sends one client event.
    public func send(_ event: Outgoing) async throws {
        let data = try JSONEncoder.openAI.encode(event)
        try await task.send(.string(String(decoding: data, as: UTF8.self)))
    }

    /// Sends any JSON, for events this version does not model.
    public func send(json: JSONValue) async throws {
        try await task.send(.string(json.jsonString))
    }

    /// Closes the connection.
    public func close() {
        task.cancel(with: .normalClosure, reason: nil)
        session.finishTasksAndInvalidate()
    }
}

/// A Responses API WebSocket connection.
public typealias ResponsesConnection = OpenAIWebSocket<ResponsesClientEvent, ResponsesServerEvent>

public extension OpenAI {
    /// Opens a WebSocket at a path under the base URL, with the same credentials as HTTP requests.
    func webSocket<Outgoing: Encodable & Sendable, Incoming: Decodable & Sendable>(
        path: String,
        query: [URLQueryItem] = [],
        options: OpenAIRequestOptions? = nil,
        sending: Outgoing.Type = Outgoing.self,
        receiving: Incoming.Type = Incoming.self
    ) throws -> OpenAIWebSocket<Outgoing, Incoming> {
        var request = OpenAIRequest(method: "GET", path: path)
        request.query = query
        var urlRequest = try makeURLRequest(request, options: options)
        if let url = urlRequest.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.scheme = components.scheme == "http" ? "ws" : "wss"
            urlRequest.url = components.url
        }
        urlRequest.setValue(nil, forHTTPHeaderField: "Accept")
        return OpenAIWebSocket(request: urlRequest)
    }
}

public extension ResponsesResource {
    /// Opens a Responses API WebSocket, which keeps one connection open for many `response.create` events.
    func connect(options: OpenAIRequestOptions? = nil) throws -> ResponsesConnection {
        try client.webSocket(path: "/responses", options: options)
    }
}
