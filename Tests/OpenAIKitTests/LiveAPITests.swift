// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Testing
@testable import OpenAIKit

/// Runs against the real OpenAI API, only when `OPENAI_API_KEY` is set:
///
///     OPENAI_API_KEY=sk-... swift test --filter LiveAPITests
///
/// Each test makes one or two small requests, so a full run costs a fraction of a cent.
/// `OPENAIKIT_LIVE_MODEL` and `OPENAIKIT_LIVE_REALTIME_MODEL` override the models used.
@Suite("Live API", .enabled(if: LiveAPI.isEnabled, "Set OPENAI_API_KEY to run against the real API"), .serialized)
struct LiveAPITests {
    let client = OpenAI(.fromEnvironment())

    @Test func listsModels() async throws {
        let models = try await client.models.list()
        #expect(!models.data.isEmpty)
    }

    @Test func createsAResponse() async throws {
        let response = try await client.responses.create(CreateResponse(model: LiveAPI.model, input: "Reply with exactly: OpenAIKit works"))
        #expect(response.outputText.contains("OpenAIKit works"))
    }

    @Test func streamsAResponse() async throws {
        var text = ""
        var unknownTypes: [String] = []
        var completed = false
        for try await event in client.responses.createStream(CreateResponse(model: LiveAPI.model, input: "Count from 1 to 5, comma separated.")) {
            text += event.outputTextDelta ?? ""
            if case .unknown(let raw) = event { unknownTypes.append(raw["type"]?.stringValue ?? "?") }
            if event.completedResponse != nil { completed = true }
        }
        #expect(completed)
        #expect(text.contains("5"))
        #expect(unknownTypes.isEmpty, "Event types the generated code doesn't know yet: \(unknownTypes)")
    }

    @Test func streamsAChatCompletion() async throws {
        var text = ""
        for try await chunk in client.chat.completions.createStream(CreateChatCompletionRequest(model: ModelIdsShared(rawValue: LiveAPI.model.rawValue), messages: [.user(text: "Say hello in one word.")])) {
            text += chunk.contentDelta ?? ""
        }
        #expect(!text.isEmpty)
    }

    @Test func callsAFunctionAndAnswers() async throws {
        let tool = FunctionTool(
            name: "get_weather",
            description: "Current weather for a city.",
            parameters: ["type": "object", "properties": ["city": ["type": "string"]], "required": ["city"], "additionalProperties": false],
            strict: true
        )
        let first = try await client.responses.create(CreateResponse(model: LiveAPI.model, input: "What's the weather in Paris? Use the tool.", tools: [.function(tool)]))
        let call = try #require(first.functionCalls.first)
        struct Arguments: Decodable { let city: String }
        #expect(try call.decodeArguments(as: Arguments.self).city.contains("Paris"))
        let output = FunctionCallOutputItemParam(output: "18°C and sunny", callID: call.callID)
        let final = try await client.responses.create(CreateResponse(model: LiveAPI.model, input: .inputItemList([.item(.functionCallOutput(output))]), previousResponseID: first.id))
        #expect(final.outputText.contains("18"))
    }

    @Test func createsBase64Embeddings() async throws {
        let result = try await client.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: "OpenAIKit", encodingFormat: .base64))
        #expect(result.data.first?.base64Vector?.count == 1536)
    }

    @Test func talksOverRealtime() async throws {
        let connection = try client.realtime.connect(model: LiveAPI.realtimeModel)
        defer { connection.close() }
        try await connection.send(json: ["type": "session.update", "session": ["type": "realtime", "output_modalities": ["text"]]])
        try await connection.send(json: [
            "type": "conversation.item.create",
            "item": ["type": "message", "role": "user", "content": [["type": "input_text", "text": "Say hi in three words."]]],
        ])
        try await connection.send(json: ["type": "response.create"])
        var text = ""
        var unknownTypes: [String] = []
        for try await event in connection.events {
            switch event {
            case .responseOutputTextDelta(let delta): text += delta.delta
            case .unknown(let raw): unknownTypes.append(raw["type"]?.stringValue ?? "?")
            case .error(let error): Issue.record("Realtime error: \(error.error.message)")
            case .responseDone: break
            default: continue
            }
            if case .responseDone = event { break }
            if case .error = event { break }
        }
        #expect(!text.isEmpty)
        #expect(unknownTypes.isEmpty, "Event types the generated code doesn't know yet: \(unknownTypes)")
    }
}

enum LiveAPI {
    static var isEnabled: Bool {
        !(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "").isEmpty
    }

    static var model: ModelIdsResponses {
        ModelIdsResponses(rawValue: ProcessInfo.processInfo.environment["OPENAIKIT_LIVE_MODEL"] ?? "gpt-6.2-astra")
    }

    static var realtimeModel: String {
        ProcessInfo.processInfo.environment["OPENAIKIT_LIVE_REALTIME_MODEL"] ?? "gpt-realtime-2"
    }
}
