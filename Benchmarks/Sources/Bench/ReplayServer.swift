// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Network

/// A minimal HTTP/1.1 server that replays recorded OpenAI responses on 127.0.0.1.
///
/// Both SDKs under test talk to it through a real `URLSession` and real sockets, so the numbers
/// include everything an app pays for except the internet: connection handling, header parsing,
/// body delivery, SSE framing and JSON decoding.
final class ReplayServer: @unchecked Sendable {
    struct Route: Sendable {
        enum Body: Sendable {
            case json(Data)
            /// Server-sent events, written one event per TCP write.
            case events([Data], interval: TimeInterval)
        }
        var body: Body
    }

    private let listener: NWListener
    private let queue = DispatchQueue(label: "replay-server", qos: .userInitiated)
    private let lock = NSLock()
    private var routes: [String: Route] = [:]
    /// Monotonic send time of each SSE event written since the last reset, in order.
    private var sentTimes: [UInt64] = []
    private(set) var port: UInt16 = 0

    init() throws {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: .any)
        parameters.allowLocalEndpointReuse = true
        listener = try NWListener(using: parameters)
    }

    func start() throws {
        let ready = DispatchSemaphore(value: 0)
        listener.stateUpdateHandler = { state in
            if case .ready = state { ready.signal() }
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.serve(connection)
        }
        listener.start(queue: queue)
        ready.wait()
        port = listener.port?.rawValue ?? 0
    }

    func set(_ path: String, _ route: Route) {
        lock.lock(); routes[path] = route; lock.unlock()
    }

    func resetSentTimes() {
        lock.lock(); sentTimes.removeAll(keepingCapacity: true); lock.unlock()
    }

    func takeSentTimes() -> [UInt64] {
        lock.lock(); defer { lock.unlock() }
        return sentTimes
    }

    private func route(for path: String) -> Route? {
        lock.lock(); defer { lock.unlock() }
        return routes[path]
    }

    // MARK: Connection handling

    private func serve(_ connection: NWConnection) {
        connection.start(queue: queue)
        readRequest(on: connection, buffer: Data())
    }

    private func readRequest(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            var buffer = buffer
            if let data { buffer.append(data) }
            if let request = HTTPRequestHead.parse(&buffer) {
                self.respond(to: request, on: connection, remaining: buffer)
            } else if isComplete || error != nil {
                connection.cancel()
            } else {
                self.readRequest(on: connection, buffer: buffer)
            }
        }
    }

    private func respond(to request: HTTPRequestHead, on connection: NWConnection, remaining: Data) {
        // Drain the request body before answering.
        if remaining.count < request.contentLength {
            connection.receive(minimumIncompleteLength: request.contentLength - remaining.count, maximumLength: request.contentLength - remaining.count) { [weak self] data, _, _, _ in
                var full = remaining
                if let data { full.append(data) }
                self?.respond(to: request, on: connection, remaining: full)
            }
            return
        }
        let leftover = remaining.count > request.contentLength ? Data(remaining.dropFirst(request.contentLength)) : Data()
        let path = request.path.split(separator: "?").first.map(String.init) ?? request.path
        guard let route = route(for: path) else {
            send(status: "404 Not Found", body: Data(#"{"error":{"message":"No fixture for \#(path)"}}"#.utf8), on: connection, then: leftover)
            return
        }
        switch route.body {
        case .json(let body):
            send(status: "200 OK", body: body, on: connection, then: leftover)
        case .events(let events, let interval):
            let head = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: close\r\n\r\n"
            connection.send(content: Data(head.utf8), completion: .contentProcessed { [weak self] _ in
                self?.sendEvents(events[...], interval: interval, on: connection)
            })
        }
    }

    private func send(status: String, body: Data, on connection: NWConnection, then leftover: Data) {
        var response = Data("HTTP/1.1 \(status)\r\nContent-Type: application/json\r\nContent-Length: \(body.count)\r\nConnection: keep-alive\r\n\r\n".utf8)
        response.append(body)
        connection.send(content: response, completion: .contentProcessed { [weak self] error in
            if error != nil { connection.cancel(); return }
            self?.readRequest(on: connection, buffer: leftover)
        })
    }

    private func sendEvents(_ events: ArraySlice<Data>, interval: TimeInterval, on connection: NWConnection) {
        guard let event = events.first else {
            connection.send(content: nil, contentContext: .finalMessage, isComplete: true, completion: .contentProcessed { _ in
                connection.cancel()
            })
            return
        }
        let now = DispatchTime.now().uptimeNanoseconds
        lock.lock(); sentTimes.append(now); lock.unlock()
        connection.send(content: event, completion: .contentProcessed { [weak self] error in
            guard let self, error == nil else { connection.cancel(); return }
            let rest = events.dropFirst()
            if interval > 0 {
                self.queue.asyncAfter(deadline: .now() + interval) { self.sendEvents(rest, interval: interval, on: connection) }
            } else {
                self.sendEvents(rest, interval: interval, on: connection)
            }
        })
    }
}

struct HTTPRequestHead {
    var method: String
    var path: String
    var contentLength: Int

    /// Parses and removes a request head from the buffer, or returns nil if it is incomplete.
    static func parse(_ buffer: inout Data) -> HTTPRequestHead? {
        guard let end = buffer.range(of: Data("\r\n\r\n".utf8)) else { return nil }
        let head = String(decoding: buffer[buffer.startIndex..<end.lowerBound], as: UTF8.self)
        buffer = Data(buffer[end.upperBound...])
        let lines = head.components(separatedBy: "\r\n")
        let parts = lines.first?.split(separator: " ") ?? []
        guard parts.count >= 2 else { return nil }
        var length = 0
        for line in lines.dropFirst() {
            let pair = line.split(separator: ":", maxSplits: 1)
            if pair.count == 2, pair[0].lowercased() == "content-length" {
                length = Int(pair[1].trimmingCharacters(in: .whitespaces)) ?? 0
            }
        }
        return HTTPRequestHead(method: String(parts[0]), path: String(parts[1]), contentLength: length)
    }
}
