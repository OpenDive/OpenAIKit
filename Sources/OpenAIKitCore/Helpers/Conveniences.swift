// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

// Hand-written conveniences on top of the generated models.

// MARK: Responses

public extension Response {
    /// The text of every `output_text` part, joined. This is `response.output_text` in the official SDKs.
    var outputText: String {
        output.map { item -> String in
            guard case .message(let message) = item else { return "" }
            return message.content.map { part -> String in
                if case .outputText(let text) = part { return text.text }
                return ""
            }.joined()
        }.joined()
    }

    /// The function calls the model asked you to run.
    var functionCalls: [FunctionToolCall] {
        output.compactMap { item in
            if case .functionCall(let call) = item { return call }
            return nil
        }
    }

    /// Decodes `outputText` as JSON. Use this with structured outputs (`text.format` set to a JSON schema).
    func decodeOutput<T: Decodable>(as type: T.Type = T.self) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(outputText.utf8))
    }
}

public extension ResponseStreamEvent {
    /// The text added by a `response.output_text.delta` event, or `nil` for other events.
    var outputTextDelta: String? {
        if case .responseOutputTextDelta(let event) = self { return event.delta }
        return nil
    }

    /// The finished response carried by `response.completed`, or `nil` for other events.
    var completedResponse: Response? {
        if case .responseCompleted(let event) = self { return event.response }
        return nil
    }
}

public extension InputItem {
    /// A user message with text content.
    static func user(_ text: String) -> InputItem {
        .message(EasyInputMessage(role: .user, content: .textInput(text)))
    }

    /// A system message with text content.
    static func system(_ text: String) -> InputItem {
        .message(EasyInputMessage(role: .system, content: .textInput(text)))
    }

    /// A developer message with text content.
    static func developer(_ text: String) -> InputItem {
        .message(EasyInputMessage(role: .developer, content: .textInput(text)))
    }

    /// An assistant message with text content, for replaying earlier turns.
    static func assistant(_ text: String) -> InputItem {
        .message(EasyInputMessage(role: .assistant, content: .textInput(text)))
    }
}

public extension FunctionToolCall {
    /// The arguments as JSON.
    var argumentsJSON: JSONValue {
        get throws { try JSONValue(parsing: arguments) }
    }

    /// Decodes the arguments into your own type.
    func decodeArguments<T: Decodable>(as type: T.Type = T.self) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(arguments.utf8))
    }
}

// MARK: Chat Completions

public extension ChatCompletionRequestMessage {
    /// A developer message with text content.
    static func developer(text: String) -> Self {
        .developer(ChatCompletionRequestDeveloperMessage(content: .init(stringLiteral: text)))
    }

    /// A system message with text content.
    static func system(text: String) -> Self {
        .system(ChatCompletionRequestSystemMessage(content: .init(stringLiteral: text)))
    }

    /// A user message with text content.
    static func user(text: String) -> Self {
        .user(ChatCompletionRequestUserMessage(content: .init(stringLiteral: text)))
    }

    /// An assistant message with text content, for replaying earlier turns.
    static func assistant(text: String) -> Self {
        .assistant(ChatCompletionRequestAssistantMessage(content: .init(stringLiteral: text)))
    }
}

public extension CreateChatCompletionResponse {
    /// The first choice's message text, if any.
    var firstContent: String? {
        choices.first?.message.content
    }
}

public extension CreateChatCompletionStreamResponse {
    /// The text added to the first choice by this chunk, if any.
    var contentDelta: String? {
        choices.first?.delta.content
    }
}

// MARK: Embeddings

public extension Embedding {
    /// The embedding as numbers. Returns `nil` when you asked for `base64` encoding;
    /// use `base64Vector` then.
    var vector: [Double]? {
        if case .array(let values) = embedding { return values }
        return nil
    }

    /// The embedding decoded from `base64` encoding, which is smaller on the wire.
    var base64Vector: [Float]? {
        guard case .string(let text) = embedding, let data = Data(base64Encoded: text) else { return nil }
        return data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
    }
}

// MARK: Images

public extension ImageObject {
    /// The decoded image bytes when the response used `b64_json`.
    var imageData: Data? {
        b64JSON.flatMap { Data(base64Encoded: $0) }
    }
}

// MARK: Webhooks

public extension WebhooksResource {
    /// Verifies a webhook whose body you have as a string.
    func verifySignature(payload: String, headers: [String: String], secret: String? = nil, tolerance: TimeInterval = 300) throws {
        try verifySignature(payload: Data(payload.utf8), headers: headers, secret: secret, tolerance: tolerance)
    }

    /// Verifies and decodes a webhook whose body you have as a string.
    func unwrap(payload: String, headers: [String: String], secret: String? = nil, tolerance: TimeInterval = 300) throws -> WebhookEvent {
        try unwrap(payload: Data(payload.utf8), headers: headers, secret: secret, tolerance: tolerance)
    }
}
