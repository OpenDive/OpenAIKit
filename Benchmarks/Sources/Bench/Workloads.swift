// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import OpenAI
import OpenAIKit

enum SDK: String, CaseIterable, Codable, Sendable {
    case openaikit
    case macpaw
}

/// One benchmark: a request shape, the fixture the replay server answers with, and how to run it with each SDK.
struct Workload: Sendable {
    enum Kind: Sendable { case json, stream }

    var name: String
    var summary: String
    var kind: Kind
    var path: String
    var fixture: String
    var run: @Sendable (SDK, BenchClients) async throws -> Int

    static let all: [Workload] = [
        Workload(name: "models.list", summary: "GET /models", kind: .json, path: "/v1/models", fixture: "models.json") { sdk, c in
            switch sdk {
            case .openaikit: return try await c.kit.models.list().data.count
            case .macpaw: return try await c.macpaw.models().data.count
            }
        },
        Workload(name: "chat.create", summary: "Chat Completions, ~250 words", kind: .json, path: "/v1/chat/completions", fixture: "chat-create.json") { sdk, c in
            switch sdk {
            case .openaikit:
                let r = try await c.kit.chat.completions.create(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")]))
                return r.firstContent?.count ?? 0
            case .macpaw:
                let r = try await c.macpaw.chats(query: ChatQuery(messages: [.user(.init(content: .string("Hi")))], model: "gpt-6.2-astra"))
                return r.choices.first?.message.content?.count ?? 0
            }
        },
        Workload(name: "responses.create", summary: "Responses, ~250 words", kind: .json, path: "/v1/responses", fixture: "responses-create.json") { sdk, c in
            switch sdk {
            case .openaikit:
                let r = try await c.kit.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hi"))
                return r.outputText.count
            case .macpaw:
                let r = try await c.macpaw.responses.createResponse(query: CreateModelResponseQuery(input: .textInput("Hi"), model: "gpt-6.2-astra"))
                return r.output.count
            }
        },
        Workload(name: "embeddings.float", summary: "64 × 1536-dim embeddings, float JSON", kind: .json, path: "/v1/embeddings", fixture: "embeddings-float.json") { sdk, c in
            let inputs = ["a", "b"]
            switch sdk {
            case .openaikit:
                let r = try await c.kit.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: .strings(inputs)))
                return r.data.reduce(0) { $0 + ($1.vector?.count ?? 0) }
            case .macpaw:
                let r = try await c.macpaw.embeddings(query: EmbeddingsQuery(input: .stringList(inputs), model: "text-embedding-3-small"))
                return r.data.reduce(0) { $0 + $1.embedding.count }
            }
        },
        Workload(name: "chat.stream", summary: "Chat Completions stream, ~700 words", kind: .stream, path: "/v1/chat/completions", fixture: "chat-stream.sse") { sdk, c in
            var events = 0
            switch sdk {
            case .openaikit:
                for try await chunk in c.kit.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
                    events += 1
                    c.mark(chunk.contentDelta == nil ? 0 : 1)
                }
            case .macpaw:
                for try await chunk in c.macpaw.chatsStream(query: ChatQuery(messages: [.user(.init(content: .string("Hi")))], model: "gpt-6.2-astra")) {
                    events += 1
                    c.mark(chunk.choices.first?.delta.content == nil ? 0 : 1)
                }
            }
            return events
        },
        Workload(name: "responses.stream", summary: "Responses stream, ~700 words", kind: .stream, path: "/v1/responses", fixture: "responses-stream.sse") { sdk, c in
            var events = 0
            switch sdk {
            case .openaikit:
                for try await event in c.kit.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {
                    events += 1
                    c.mark(event.outputTextDelta == nil ? 0 : 1)
                }
            case .macpaw:
                for try await _ in c.macpaw.responses.createResponseStreaming(query: CreateModelResponseQuery(input: .textInput("Hi"), model: "gpt-6.2-astra", stream: true)) {
                    events += 1
                    c.mark(1)
                }
            }
            return events
        },
    ]
}

/// Both SDKs pointed at the replay server, plus a clock for per-event arrival times.
final class BenchClients: @unchecked Sendable {
    let kit: KitClient
    let macpaw: MacPawClient
    private let lock = NSLock()
    private var arrivals: [UInt64] = []

    init(port: UInt16) {
        kit = makeKitClient(port: port)
        macpaw = makeMacPawClient(port: port)
    }

    /// Records the arrival time of one stream event.
    func mark(_ value: Int) {
        let time = now()
        lock.lock(); arrivals.append(time); lock.unlock()
        _ = value
    }

    func resetArrivals() {
        lock.lock(); arrivals.removeAll(keepingCapacity: true); lock.unlock()
    }

    func takeArrivals() -> [UInt64] {
        lock.lock(); defer { lock.unlock() }
        return arrivals
    }
}
