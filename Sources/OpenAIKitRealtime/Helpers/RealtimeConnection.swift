// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import OpenAIKitCore

/// A Realtime API WebSocket connection.
public typealias RealtimeConnection = OpenAIWebSocket<RealtimeClientEvent, RealtimeServerEvent>

/// A realtime translation WebSocket connection.
public typealias RealtimeTranslationConnection = OpenAIWebSocket<RealtimeTranslationClientEvent, RealtimeTranslationServerEvent>

public extension RealtimeResource {
    /// Connects to the Realtime API over WebSocket.
    ///
    /// - Parameters:
    ///   - model: The realtime model. Omit it when you connect to an existing SIP call with `callID`.
    ///   - callID: Attach to an incoming call instead of starting a new session.
    ///   - options: Per-connection header and query overrides.
    func connect(model: String? = nil, callID: String? = nil, options: OpenAIRequestOptions? = nil) throws -> RealtimeConnection {
        var query: [URLQueryItem] = []
        if let model { query.append(URLQueryItem(name: "model", value: model)) }
        if let callID { query.append(URLQueryItem(name: "call_id", value: callID)) }
        return try client.webSocket(path: "/realtime", query: query, options: options)
    }

    /// Connects to the realtime translation WebSocket.
    func connectTranslation(model: String, options: OpenAIRequestOptions? = nil) throws -> RealtimeTranslationConnection {
        try client.webSocket(path: "/realtime/translations", query: [URLQueryItem(name: "model", value: model)], options: options)
    }
}
