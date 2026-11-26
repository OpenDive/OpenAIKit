// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Testing
@testable import OpenAIKit

@Suite("Server-sent events")
struct ServerSentEventParserTests {
    @Test func parsesEventsAcrossChunkBoundaries() {
        var parser = ServerSentEventParser()
        let text = "event: greeting\r\ndata: hello\r\n\r\n: a comment\n\ndata: line 1\ndata: line 2\nid: 7\n\n"
        var events: [ServerSentEvent] = []
        for byte in Data(text.utf8) {
            events += parser.feed(Data([byte]))
        }
        events += parser.finish()
        #expect(events == [
            ServerSentEvent(event: "greeting", data: "hello", id: nil, retry: nil),
            ServerSentEvent(event: nil, data: "line 1\nline 2", id: "7", retry: nil),
        ])
    }

    @Test func flushesAFinalEventWithoutATrailingBlankLine() {
        var parser = ServerSentEventParser()
        #expect(parser.feed(Data("data: {\"a\":1}".utf8)).isEmpty)
        #expect(parser.finish() == [ServerSentEvent(event: nil, data: "{\"a\":1}", id: nil, retry: nil)])
    }

    @Test func treatsAFieldWithoutAColonAsEmpty() {
        var parser = ServerSentEventParser()
        let events = parser.feed(Data("data\n\n".utf8))
        #expect(events == [ServerSentEvent(event: nil, data: "", id: nil, retry: nil)])
    }
}

@Suite("Streaming")
struct StreamingTests {
    @Test func streamsResponseEventsAndSetsStreamTrue() async throws {
        let sse = """
        event: response.created
        data: {"type":"response.created","sequence_number":0,"response":\(responseJSON.replacingOccurrences(of: "\n", with: ""))}

        event: response.output_text.delta
        data: {"type":"response.output_text.delta","sequence_number":1,"item_id":"msg_1","output_index":0,"content_index":0,"delta":"Hel","logprobs":[]}

        event: response.output_text.delta
        data: {"type":"response.output_text.delta","sequence_number":2,"item_id":"msg_1","output_index":0,"content_index":0,"delta":"lo","logprobs":[]}

        event: response.brand_new_event
        data: {"type":"response.brand_new_event","sequence_number":3}

        """
        let (client, transport) = makeClient([.sse(sse)])
        var text = ""
        var unknown = 0
        for try await event in client.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {
            if let delta = event.outputTextDelta { text += delta }
            if case .unknown = event { unknown += 1 }
        }
        #expect(text == "Hello")
        #expect(unknown == 1, "Unknown event types decode as .unknown instead of failing the stream")
        let request = try #require(transport.lastRequest)
        #expect(request.bodyJSON?["stream"] == true)
        #expect(request.value(forHTTPHeaderField: "Accept") == "text/event-stream")
    }

    @Test func stopsAtDoneForChatCompletions() async throws {
        let chunk = #"{"id":"c1","object":"chat.completion.chunk","created":1,"model":"gpt-6.2-astra","choices":[{"index":0,"delta":{"content":"Hi"},"finish_reason":null}]}"#
        let (client, _) = makeClient([.sse("data: \(chunk)\n\ndata: [DONE]\n\ndata: \(chunk)\n\n")])
        var deltas: [String] = []
        let request = CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hello")])
        for try await chunk in client.chat.completions.createStream(request) {
            deltas.append(chunk.contentDelta ?? "")
        }
        #expect(deltas == ["Hi"])
    }

    @Test func throwsErrorsSentInsideTheStream() async throws {
        let (client, _) = makeClient([.sse("data: {\"error\":{\"message\":\"overloaded\",\"type\":\"server_error\"}}\n\n")])
        let request = CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hello")])
        do {
            for try await _ in client.chat.completions.createStream(request) {}
            Issue.record("Expected an error")
        } catch let error as OpenAIAPIError {
            #expect(error.kind == .streamError)
            #expect(error.message == "overloaded")
        }
    }

    @Test func yieldsTypedResponsesErrorEvents() async throws {
        let sse = "event: error\ndata: {\"type\":\"error\",\"code\":\"server_error\",\"message\":\"try again\",\"param\":null,\"sequence_number\":1}\n\n"
        let (client, _) = makeClient([.sse(sse)])
        var messages: [String] = []
        for try await event in client.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {
            if case .error(let error) = event { messages.append(error.message) }
        }
        #expect(messages == ["try again"])
    }

    @Test func throwsHTTPErrorsBeforeTheStreamStarts() async throws {
        let configuration = Configuration(apiKey: "sk", requestOptions: OpenAIRequestOptions(maxRetries: 0))
        let (client, _) = makeClient([.json(#"{"error":{"message":"nope"}}"#, status: 401)], configuration: configuration)
        do {
            for try await _ in client.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {}
            Issue.record("Expected an error")
        } catch let error as OpenAIAPIError {
            #expect(error.kind == .authentication)
        }
    }

    @Test func wrapsAssistantStreamEvents() async throws {
        let thread = #"{"id":"thread_1","object":"thread","created_at":1,"metadata":{},"tool_resources":{}}"#
        let (client, _) = makeClient([.sse("event: thread.created\ndata: \(thread)\n\nevent: done\ndata: [DONE]\n\n")])
        var events: [AssistantStreamEvent] = []
        for try await event in client.beta.threads.createAndRunStream(CreateThreadAndRunRequest(assistantID: "asst_1")) {
            events.append(event)
        }
        #expect(events.count == 1)
        if case .unknown(let raw) = events.first {
            Issue.record("Expected a typed event, got \(raw)")
        }
    }
}
