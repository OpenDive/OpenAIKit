// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import OpenAIKit
@testable import OpenAIKitCore

@Suite("Requests")
struct RequestTests {
    @Test func sendsCredentialsAndDefaultHeaders() async throws {
        let configuration = Configuration(apiKey: "sk-test", organizationId: "org_1", projectId: "proj_1")
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[]}"#)], configuration: configuration)
        _ = try await client.models.list()
        let request = try #require(transport.lastRequest)
        #expect(request.url?.absoluteString == "https://api.openai.com/v1/models")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer sk-test")
        #expect(request.value(forHTTPHeaderField: "OpenAI-Organization") == "org_1")
        #expect(request.value(forHTTPHeaderField: "OpenAI-Project") == "proj_1")
        #expect(request.value(forHTTPHeaderField: "User-Agent") == "OpenAIKit/\(OpenAIKitVersion.current) (Swift)")
    }

    @Test func encodesJSONBodies() async throws {
        let (client, transport) = makeClient([.json(responseJSON)])
        let response = try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hello", temperature: 0.5))
        #expect(response.id == "resp_1")
        let request = try #require(transport.lastRequest)
        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/v1/responses")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try #require(request.bodyJSON)
        #expect(body["model"] == "gpt-6.2-astra")
        #expect(body["input"] == "Hello")
        #expect(body["temperature"] == 0.5)
        #expect(body["stream"] == nil, "nil optionals are omitted")
    }

    @Test func escapesPathParameters() async throws {
        let (client, transport) = makeClient([.json(#"{"id":"a b/c","object":"model","created":1,"owned_by":"me"}"#)])
        _ = try await client.models.retrieve(model: "a b/c")
        #expect(transport.lastRequest?.url?.absoluteString == "https://api.openai.com/v1/models/a%20b%2Fc")
    }

    @Test func encodesQueryParametersTheWayTheAPIExpects() throws {
        var request = OpenAIRequest(method: "GET", path: "/x")
        try request.addQuery("limit", 20)
        try request.addQuery("include", ["a", "b"])
        try request.addQuery("ids[]", ["c"])
        try request.addQuery("metadata", ["k": "v"] as [String: String])
        try request.addQuery("missing", nil as String?)
        try request.addQuery("flag", true)
        let pairs = request.query.map { "\($0.name)=\($0.value ?? "")" }
        #expect(pairs == ["limit=20", "include[]=a", "include[]=b", "ids[]=c", "metadata[k]=v", "flag=true"])
    }

    @Test func sendsBetaHeadersForBetaResources() async throws {
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}"#)])
        _ = try await client.vectorStores.list()
        #expect(transport.lastRequest?.value(forHTTPHeaderField: "OpenAI-Beta") == "assistants=v2")
    }

    @Test func usesTheAdminKeyForAdministrationOperations() async throws {
        let configuration = Configuration(apiKey: "sk-test", adminAPIKey: "sk-admin")
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}"#)], configuration: configuration)
        _ = try await client.admin.organization.users.list()
        #expect(transport.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer sk-admin")
        #expect(transport.lastRequest?.url?.path == "/v1/organization/users")
    }

    @Test func requiresAnAdminKeyForAdministrationOperations() async throws {
        let (client, transport) = makeClient([])
        await #expect(throws: OpenAIError.self) {
            _ = try await client.admin.organization.users.list()
        }
        #expect(transport.requestCount == 0)
    }

    @Test func requiresAnAPIKey() async throws {
        let (client, _) = makeClient([], configuration: Configuration())
        do {
            _ = try await client.models.list()
            Issue.record("Expected an error")
        } catch OpenAIError.missingAPIKey {
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func proxiesWithoutAnAPIKey() async throws {
        // Your server holds the key; the app authenticates to it with its own header.
        let configuration = Configuration(
            baseURL: URL(string: "https://proxy.example.com/openai/v1")!,
            requestOptions: OpenAIRequestOptions(additionalHeaders: ["X-Session": "user-token"])
        )
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[]}"#)], configuration: configuration)
        _ = try await client.models.list()
        let request = try #require(transport.lastRequest)
        #expect(request.url?.absoluteString == "https://proxy.example.com/openai/v1/models")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(request.value(forHTTPHeaderField: "X-Session") == "user-token")
    }

    @Test func letsAProxyReplaceTheAuthorizationHeader() async throws {
        let configuration = Configuration(
            baseURL: URL(string: "https://proxy.example.com/v1")!,
            requestOptions: OpenAIRequestOptions(additionalHeaders: ["Authorization": "Bearer user-session"])
        )
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[]}"#)], configuration: configuration)
        _ = try await client.models.list()
        #expect(transport.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer user-session")
    }

    @Test func appliesPerRequestOptions() async throws {
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[]}"#)])
        let options = OpenAIRequestOptions(timeoutInterval: 5, additionalHeaders: ["X-Trace": "1"], additionalQuery: ["debug": "yes"])
        _ = try await client.models.list(options: options)
        let request = try #require(transport.lastRequest)
        #expect(request.timeoutInterval == 5)
        #expect(request.value(forHTTPHeaderField: "X-Trace") == "1")
        #expect(request.queryItems.contains(URLQueryItem(name: "debug", value: "yes")))
    }

    @Test func honorsACustomBaseURL() async throws {
        let configuration = Configuration(apiKey: "sk", baseURL: URL(string: "http://localhost:8080/proxy/v1/")!)
        let (client, transport) = makeClient([.json(#"{"object":"list","data":[]}"#)], configuration: configuration)
        _ = try await client.models.list()
        #expect(transport.lastRequest?.url?.absoluteString == "http://localhost:8080/proxy/v1/models")
    }

    @Test func readsConfigurationFromTheEnvironment() {
        let configuration = Configuration.fromEnvironment([
            "OPENAI_API_KEY": "sk-env", "OPENAI_ADMIN_KEY": "sk-admin", "OPENAI_ORG_ID": "org",
            "OPENAI_PROJECT_ID": "proj", "OPENAI_WEBHOOK_SECRET": "whsec", "OPENAI_BASE_URL": "https://example.com/v1",
        ])
        #expect(configuration.apiKey == "sk-env")
        #expect(configuration.adminAPIKey == "sk-admin")
        #expect(configuration.organizationId == "org")
        #expect(configuration.projectId == "proj")
        #expect(configuration.webhookSecret == "whsec")
        #expect(configuration.baseURL.absoluteString == "https://example.com/v1")
    }
}

@Suite("Multipart")
struct MultipartTests {
    @Test func uploadsFilesAsMultipartFormData() async throws {
        let (client, transport) = makeClient([.json(#"{"id":"file_1","object":"file","bytes":3,"created_at":1,"filename":"a.jsonl","purpose":"batch","status":"processed"}"#)])
        let file = FileUpload(data: Data("abc".utf8), filename: "a.jsonl")
        let created = try await client.files.create(CreateFileRequest(file: file, purpose: .batch))
        #expect(created.id == "file_1")
        let request = try #require(transport.lastRequest)
        let contentType = try #require(request.value(forHTTPHeaderField: "Content-Type"))
        #expect(contentType.hasPrefix("multipart/form-data; boundary="))
        let body = request.bodyText
        #expect(body.contains("Content-Disposition: form-data; name=\"file\"; filename=\"a.jsonl\"\r\nContent-Type: application/jsonl\r\n\r\nabc\r\n"))
        #expect(body.contains("Content-Disposition: form-data; name=\"purpose\"\r\n\r\nbatch\r\n"))
    }

    @Test func flattensArraysAndObjectsWithBrackets() throws {
        struct Form: Encodable {
            var images: [FileUpload]
            var tags: [String]
            var options: [String: Int]
        }
        var request = OpenAIRequest(method: "POST", path: "/x")
        let png = FileUpload(data: Data([1, 2]), filename: "a.png")
        try request.setMultipartBody(Form(images: [png, png], tags: ["x", "y"], options: ["n": 2]), overrides: ["stream": true])
        guard case .multipart(let parts) = request.body else {
            Issue.record("Expected multipart")
            return
        }
        #expect(parts == [
            .file(name: "images[]", file: png), .file(name: "images[]", file: png),
            .text(name: "options[n]", value: "2"),
            .text(name: "stream", value: "true"),
            .text(name: "tags[]", value: "x"), .text(name: "tags[]", value: "y"),
        ])
    }

    @Test func derivesContentTypesFromFileNames() {
        #expect(FileUpload(data: Data(), filename: "speech.mp3").resolvedContentType == "audio/mpeg")
        #expect(FileUpload(data: Data(), filename: "photo.PNG").resolvedContentType == "image/png")
        #expect(FileUpload(data: Data(), filename: "blob").resolvedContentType == "application/octet-stream")
        #expect(FileUpload(data: Data(), filename: "x.png", contentType: "image/x").resolvedContentType == "image/x")
    }
}

@Suite("Errors and retries")
struct RetryTests {
    let fast = Configuration(apiKey: "sk", requestOptions: OpenAIRequestOptions(maxRetries: 2))

    @Test func decodesAPIErrors() async throws {
        let body = #"{"error":{"message":"Bad model","type":"invalid_request_error","param":"model","code":"model_not_found"}}"#
        let (client, transport) = makeClient([.json(body, status: 404, headers: ["x-request-id": "req_9"])], configuration: fast)
        do {
            _ = try await client.models.list()
            Issue.record("Expected an error")
        } catch let error as OpenAIAPIError {
            #expect(error.statusCode == 404)
            #expect(error.kind == .notFound)
            #expect(error.message == "Bad model")
            #expect(error.type == "invalid_request_error")
            #expect(error.param == "model")
            #expect(error.code == "model_not_found")
            #expect(error.requestID == "req_9")
        }
        #expect(transport.requestCount == 1, "4xx other than 408/409/429 is not retried")
    }

    @Test func retriesRateLimitsAndServerErrors() async throws {
        let (client, transport) = makeClient([
            .json("{}", status: 429, headers: ["retry-after-ms": "1"]),
            .json("{}", status: 503, headers: ["retry-after-ms": "1"]),
            .json(#"{"object":"list","data":[]}"#),
        ], configuration: fast)
        _ = try await client.models.list()
        #expect(transport.requestCount == 3)
    }

    @Test func stopsAfterMaxRetries() async throws {
        let replies = Array(repeating: MockTransport.Reply.json("{}", status: 500, headers: ["retry-after-ms": "1"]), count: 5)
        let (client, transport) = makeClient(replies, configuration: fast)
        await #expect(throws: OpenAIAPIError.self) { _ = try await client.models.list() }
        #expect(transport.requestCount == 3)
    }

    @Test func respectsShouldRetryHeader() async throws {
        let (client, transport) = makeClient([.json("{}", status: 500, headers: ["x-should-retry": "false"])], configuration: fast)
        await #expect(throws: OpenAIAPIError.self) { _ = try await client.models.list() }
        #expect(transport.requestCount == 1)
    }

    @Test func backoffGrowsAndIsCapped() {
        #expect(OpenAI.retryDelay(attempt: 0, headers: [:]) <= 0.5)
        #expect(OpenAI.retryDelay(attempt: 0, headers: [:]) >= 0.375)
        #expect(OpenAI.retryDelay(attempt: 10, headers: [:]) <= 8)
        #expect(OpenAI.retryDelay(attempt: 3, headers: ["retry-after": "2"]) == 2)
        #expect(!OpenAI.shouldRetry(status: 429, headers: ["retry-after": "600"]))
    }

    @Test func reportsDecodingErrorsWithTheBody() async throws {
        let (client, _) = makeClient([.json(#"{"unexpected":true}"#)], configuration: fast)
        do {
            _ = try await client.models.retrieve(model: "x")
            Issue.record("Expected an error")
        } catch OpenAIError.decoding(let type, _, let body) {
            #expect(type == "Model")
            #expect(String(decoding: body, as: UTF8.self) == #"{"unexpected":true}"#)
        }
    }
}

@Suite("Cancellation")
struct CancellationTests {
    /// A transport that never answers on its own: it suspends until the calling task is
    /// cancelled, and records that it was. A 60-second fallback turns a regression into a
    /// test failure instead of a hang.
    final class SuspendingTransport: OpenAIHTTPTransport, @unchecked Sendable {
        private let lock = NSLock()
        private var started: CheckedContinuation<Void, Never>?
        private var didStart = false
        private(set) var cancelled = false

        /// Returns once a request has reached the transport.
        func waitUntilStarted() async {
            await withCheckedContinuation { continuation in
                register(continuation)
            }
        }

        private func register(_ continuation: CheckedContinuation<Void, Never>) {
            lock.lock()
            if didStart {
                lock.unlock()
                continuation.resume()
            } else {
                started = continuation
                lock.unlock()
            }
        }

        private func markStarted() {
            lock.lock()
            didStart = true
            let waiter = started
            started = nil
            lock.unlock()
            waiter?.resume()
        }

        private var finished: Bool?
        private var finishWaiter: CheckedContinuation<Bool, Never>?

        private func markFinished(cancelled: Bool) {
            lock.lock()
            self.cancelled = cancelled
            finished = cancelled
            let waiter = finishWaiter
            finishWaiter = nil
            lock.unlock()
            waiter?.resume(returning: cancelled)
        }

        /// Returns whether the request ended because it was cancelled (`false` after the fallback).
        func waitUntilFinished() async -> Bool {
            await withCheckedContinuation { continuation in
                registerFinish(continuation)
            }
        }

        private func registerFinish(_ continuation: CheckedContinuation<Bool, Never>) {
            lock.lock()
            if let finished {
                lock.unlock()
                continuation.resume(returning: finished)
            } else {
                finishWaiter = continuation
                lock.unlock()
            }
        }

        private func suspend() async throws -> Never {
            markStarted()
            do {
                try await Task.sleep(nanoseconds: 60_000_000_000)
            } catch is CancellationError {
                markFinished(cancelled: true)
                throw CancellationError()
            }
            markFinished(cancelled: false)
            throw URLError(.timedOut)
        }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            try await suspend()
        }

        func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
            try await suspend()
        }
    }

    @Test func cancellingTheTaskCancelsTheRequest() async throws {
        let transport = SuspendingTransport()
        let client = OpenAI(Configuration(apiKey: "sk"), transport: transport)
        let task = Task { try await client.models.list() }
        await transport.waitUntilStarted()
        task.cancel()
        let result = await task.result
        guard case .failure(let error) = result else {
            Issue.record("Expected a failure")
            return
        }
        #expect(error is CancellationError, "Got \(error)")
        #expect(await transport.waitUntilFinished(), "Cancellation must reach the transport")
    }

    @Test func cancellingTheStreamCancelsTheRequest() async throws {
        let transport = SuspendingTransport()
        let client = OpenAI(Configuration(apiKey: "sk"), transport: transport)
        let task = Task {
            for try await _ in client.responses.createStream(CreateResponse(model: "gpt-6.2-astra", input: "Hi")) {}
        }
        await transport.waitUntilStarted()
        task.cancel()
        _ = await task.result
        #expect(await transport.waitUntilFinished(), "Cancellation must reach the transport")
    }
}

@Suite("Pagination")
struct PaginationTests {
    @Test func listAllFollowsCursors() async throws {
        func file(_ id: String) -> String {
            #"{"id":"\#(id)","object":"file","bytes":1,"created_at":1,"filename":"f","purpose":"batch","status":"processed"}"#
        }
        let (client, transport) = makeClient([
            .json(#"{"object":"list","data":[\#(file("a")),\#(file("b"))],"first_id":"a","last_id":"b","has_more":true}"#),
            .json(#"{"object":"list","data":[\#(file("c"))],"first_id":"c","last_id":"c","has_more":false}"#),
        ])
        let ids = try await client.files.listAll(limit: 2).collect().map(\.id)
        #expect(ids == ["a", "b", "c"])
        #expect(transport.requestCount == 2)
        #expect(transport.lastRequest?.queryItems.contains(URLQueryItem(name: "after", value: "b")) == true)
        #expect(transport.lastRequest?.queryItems.contains(URLQueryItem(name: "limit", value: "2")) == true)
    }
}

let responseJSON = #"""
{"id":"resp_1","object":"response","created_at":1741476542,"status":"completed","model":"gpt-6.2-astra",
 "output":[{"type":"message","id":"msg_1","status":"completed","role":"assistant",
   "content":[{"type":"output_text","text":"Hello ","annotations":[],"logprobs":[]},{"type":"output_text","text":"there","annotations":[],"logprobs":[]}]},
  {"type":"function_call","id":"fc_1","call_id":"call_1","name":"lookup","arguments":"{\"city\":\"Paris\"}","status":"completed"}],
 "parallel_tool_calls":true,"tools":[],"tool_choice":"auto"}
"""#
