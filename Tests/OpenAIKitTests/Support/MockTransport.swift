// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import OpenAIKit

/// A transport that records requests and replies from a queue of canned responses.
final class MockTransport: OpenAIHTTPTransport, @unchecked Sendable {
    struct Reply {
        var status: Int
        var body: Data
        var headers: [String: String]

        static func json(_ text: String, status: Int = 200, headers: [String: String] = [:]) -> Reply {
            Reply(status: status, body: Data(text.utf8), headers: ["Content-Type": "application/json"].merging(headers) { _, new in new })
        }

        static func sse(_ text: String) -> Reply {
            Reply(status: 200, body: Data(text.utf8), headers: ["Content-Type": "text/event-stream"])
        }
    }

    private let lock = NSLock()
    private var replies: [Reply]
    private(set) var requests: [URLRequest] = []

    init(_ replies: [Reply]) {
        self.replies = replies
    }

    var lastRequest: URLRequest? {
        lock.lock(); defer { lock.unlock() }
        return requests.last
    }

    var requestCount: Int {
        lock.lock(); defer { lock.unlock() }
        return requests.count
    }

    private func next(_ request: URLRequest) -> (Data, HTTPURLResponse) {
        lock.lock()
        requests.append(request)
        let reply = replies.isEmpty ? Reply.json("{}") : replies.removeFirst()
        lock.unlock()
        let response = HTTPURLResponse(url: request.url!, statusCode: reply.status, httpVersion: "HTTP/1.1", headerFields: reply.headers)!
        return (reply.body, response)
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        next(request)
    }

    func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        let (body, response) = next(request)
        // Deliver the body in small chunks to exercise the incremental SSE parser.
        let stream = AsyncThrowingStream<Data, any Error> { continuation in
            var index = body.startIndex
            while index < body.endIndex {
                let end = body.index(index, offsetBy: 7, limitedBy: body.endIndex) ?? body.endIndex
                continuation.yield(body.subdata(in: index..<end))
                index = end
            }
            continuation.finish()
        }
        return (stream, response)
    }
}

func makeClient(_ replies: [MockTransport.Reply], configuration: Configuration = Configuration(apiKey: "sk-test")) -> (OpenAI, MockTransport) {
    let transport = MockTransport(replies)
    var configuration = configuration
    configuration.requestOptions.maxRetries = configuration.requestOptions.maxRetries ?? 2
    return (OpenAI(configuration, transport: transport), transport)
}

extension URLRequest {
    var bodyJSON: JSONValue? {
        httpBody.flatMap { try? JSONDecoder().decode(JSONValue.self, from: $0) }
    }

    var bodyText: String {
        httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
    }

    var queryItems: [URLQueryItem] {
        url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
    }
}

enum Fixtures {
    static func url(_ name: String) -> URL {
        Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")!
    }
}
