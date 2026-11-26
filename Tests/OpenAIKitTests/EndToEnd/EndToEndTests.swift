// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

#if canImport(Network)
import Foundation
import Testing
@testable import OpenAIKit

/// Responses recorded from the live API, replayed by a local server.
enum Recorded {
    static func data(_ name: String) throws -> Data {
        try Data(contentsOf: Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures/Recorded")!)
    }

    /// A recorded event stream split into events, each with its trailing blank line.
    static func events(_ name: String) throws -> [Data] {
        let text = String(decoding: try data(name), as: UTF8.self).replacingOccurrences(of: "\r\n", with: "\n")
        return text.components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { Data(($0 + "\n\n").utf8) }
    }

    /// The JSON payloads of a recorded stream, without `[DONE]`.
    static func payloads(_ name: String) throws -> [[String: Any]] {
        try events(name).compactMap { event in
            let text = String(decoding: event, as: UTF8.self)
            guard let line = text.split(separator: "\n").first(where: { $0.hasPrefix("data:") }) else { return nil }
            let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
            guard payload != "[DONE]" else { return nil }
            return try JSONSerialization.jsonObject(with: Data(payload.utf8)) as? [String: Any]
        }
    }
}

/// Starts a replay server with routes, and a client pointed at it.
func replay(
    _ routes: [String: ReplayServer.Route],
    maxRetries: Int = 0
) throws -> (OpenAI, ReplayServer) {
    let server = try ReplayServer()
    try server.start()
    for (path, route) in routes { server.set(path, route) }
    let client = OpenAI(Configuration(
        apiKey: "sk-test",
        baseURL: URL(string: "http://127.0.0.1:\(server.port)/v1")!,
        requestOptions: OpenAIRequestOptions(timeoutInterval: 30, maxRetries: maxRetries)
    ))
    return (client, server)
}

@Suite("End to end: recorded API traffic over a local server", .serialized)
struct EndToEndTests {
    @Test func listsModels() async throws {
        let (client, server) = try replay(["/v1/models": .init(body: .json(try Recorded.data("models.json")))])
        defer { server.stop() }
        let expected = try JSONSerialization.jsonObject(with: try Recorded.data("models.json")) as? [String: Any]
        let models = try await client.models.list()
        #expect(models.data.count == (expected?["data"] as? [Any])?.count)
        #expect(models.data.allSatisfy { !$0.id.isEmpty })
    }

    @Test func createsAChatCompletion() async throws {
        let (client, server) = try replay(["/v1/chat/completions": .init(body: .json(try Recorded.data("chat-create.json")))])
        defer { server.stop() }
        let completion = try await client.chat.completions.create(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")]))
        #expect((completion.firstContent ?? "").count > 200)
        #expect(completion.usage != nil)
    }

    @Test func createsAResponse() async throws {
        let (client, server) = try replay(["/v1/responses": .init(body: .json(try Recorded.data("responses-create.json")))])
        defer { server.stop() }
        let response = try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hi"))
        #expect(response.outputText.count > 200)
        #expect(response.status == .completed)
    }

    @Test func decodesFloatAndBase64Embeddings() async throws {
        let (client, server) = try replay(["/v1/embeddings": .init(body: .json(try Recorded.data("embeddings-float.json")))])
        defer { server.stop() }
        let floats = try await client.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: "a"))
        #expect(floats.data.count == 4)
        #expect(floats.data.allSatisfy { $0.vector?.count == 1536 })

        server.set("/v1/embeddings", .init(body: .json(try Recorded.data("embeddings-base64.json"))))
        let packed = try await client.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: "a", encodingFormat: .base64))
        #expect(packed.data.count == 4)
        #expect(packed.data.allSatisfy { $0.base64Vector?.count == 1536 })
    }

    @Test func streamsEveryChatChunkInOrder() async throws {
        let (client, server) = try replay(["/v1/chat/completions": .init(body: .events(try Recorded.events("chat-stream.sse"), interval: 0))])
        defer { server.stop() }
        let payloads = try Recorded.payloads("chat-stream.sse")
        let expectedText = payloads.compactMap { (($0["choices"] as? [[String: Any]])?.first?["delta"] as? [String: Any])?["content"] as? String }.joined()

        var chunks = 0
        var text = ""
        for try await chunk in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
            chunks += 1
            text += chunk.contentDelta ?? ""
        }
        #expect(chunks == payloads.count)
        #expect(text == expectedText)
        #expect(text.count > 2000)
    }

    @Test func streamsAResponseThatMatchesItsFinalOutput() async throws {
        let (client, server) = try replay(["/v1/responses": .init(body: .events(try Recorded.events("responses-stream.sse"), interval: 0))])
        defer { server.stop() }
        var events = 0
        var unknown = 0
        var deltas = ""
        var completed: Response?
        for try await event in client.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {
            events += 1
            if case .unknown = event { unknown += 1 }
            deltas += event.outputTextDelta ?? ""
            if let response = event.completedResponse { completed = response }
        }
        #expect(events == (try Recorded.payloads("responses-stream.sse")).count)
        #expect(unknown == 0, "Every recorded event type has a typed case")
        let final = try #require(completed)
        #expect(deltas == final.outputText)
    }

    @Test func deliversEventsAsTheyArrive() async throws {
        // One event every 2 ms: the first events must reach the app long before the stream ends.
        let events = Array(try Recorded.events("chat-stream.sse").prefix(60))
        let (client, server) = try replay(["/v1/chat/completions": .init(body: .events(events, interval: 0.002))])
        defer { server.stop() }
        let start = Date()
        var firstArrival: TimeInterval?
        for try await _ in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
            if firstArrival == nil { firstArrival = Date().timeIntervalSince(start) }
        }
        let total = Date().timeIntervalSince(start)
        let first = try #require(firstArrival)
        #expect(total > 0.08, "The server paced \(events.count) events over at least 118 ms")
        #expect(first < total / 2, "First event arrived at \(first)s of \(total)s: the stream was buffered")
    }

    @Test func stopsReceivingWhenTheConsumerStops() async throws {
        let events = try Recorded.events("chat-stream.sse")
        let (client, server) = try replay(["/v1/chat/completions": .init(body: .events(events, interval: 0.005))])
        defer { server.stop() }
        let start = Date()
        var received = 0
        for try await _ in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
            received += 1
            if received == 5 { break }
        }
        #expect(received == 5)
        #expect(Date().timeIntervalSince(start) < 2, "Breaking out of the loop must not wait for the rest of the stream")
    }

    @Test func cancelsAStreamFromItsTask() async throws {
        let events = try Recorded.events("chat-stream.sse")
        let (client, server) = try replay(["/v1/chat/completions": .init(body: .events(events, interval: 0.005))])
        defer { server.stop() }
        let task = Task {
            var received = 0
            for try await _ in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
                received += 1
            }
            return received
        }
        try await Task.sleep(nanoseconds: 60_000_000)
        let start = Date()
        task.cancel()
        let received = (try? await task.value) ?? 0
        #expect(Date().timeIntervalSince(start) < 2)
        #expect(received < events.count)
    }

    @Test func reusesConnectionsAcrossRequests() async throws {
        let (client, server) = try replay(["/v1/models": .init(body: .json(try Recorded.data("models.json")))])
        defer { server.stop() }
        for _ in 0..<20 { _ = try await client.models.list() }
        #expect(server.servedPaths.count == 20)
        #expect(server.connectionCount < 20, "Sequential requests should reuse keep-alive connections")
    }

    @Test func handlesConcurrentRequests() async throws {
        let (client, server) = try replay(["/v1/responses": .init(body: .json(try Recorded.data("responses-create.json")))])
        defer { server.stop() }
        let texts = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<16 {
                group.addTask { try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hi")).outputText }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        #expect(texts.count == 16)
        #expect(Set(texts).count == 1)
    }

    @Test func reportsHTTPErrorsFromTheServer() async throws {
        let (client, server) = try replay([:])
        defer { server.stop() }
        do {
            _ = try await client.models.list()
            Issue.record("Expected an error")
        } catch let error as OpenAIAPIError {
            #expect(error.statusCode == 404)
            #expect(error.message.contains("No fixture"))
        }
    }
}
#endif
