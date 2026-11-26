// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// One server-sent event.
public struct ServerSentEvent: Sendable, Hashable {
    public var event: String?
    public var data: String
    public var id: String?
    public var retry: Int?
}

/// Incremental parser for the `text/event-stream` format.
///
/// Feed it chunks of bytes as they arrive; it returns each complete event.
/// Follows the WHATWG rules: lines end with LF, CR or CRLF, a blank line ends an event,
/// lines starting with `:` are comments, and repeated `data:` lines join with newlines.
public struct ServerSentEventParser: Sendable {
    private var buffer = Data()
    private var event: String?
    private var dataLines: [String] = []
    private var id: String?
    private var retry: Int?
    private var sawField = false
    private var pendingCR = false

    public init() {}

    public mutating func feed(_ chunk: Data) -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        for byte in chunk {
            if pendingCR {
                pendingCR = false
                if byte == 0x0A { continue }
            }
            if byte == 0x0A || byte == 0x0D {
                if byte == 0x0D { pendingCR = true }
                let line = String(decoding: buffer, as: UTF8.self)
                buffer.removeAll(keepingCapacity: true)
                if let event = process(line) { events.append(event) }
            } else {
                buffer.append(byte)
            }
        }
        return events
    }

    /// Flushes an event that was not followed by a blank line before the stream ended.
    public mutating func finish() -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        if !buffer.isEmpty {
            let line = String(decoding: buffer, as: UTF8.self)
            buffer.removeAll()
            if let event = process(line) { events.append(event) }
        }
        if let event = process("") { events.append(event) }
        return events
    }

    private mutating func process(_ line: String) -> ServerSentEvent? {
        if line.isEmpty {
            defer {
                event = nil
                dataLines = []
                retry = nil
                sawField = false
            }
            guard sawField else { return nil }
            return ServerSentEvent(event: event, data: dataLines.joined(separator: "\n"), id: id, retry: retry)
        }
        if line.hasPrefix(":") { return nil }
        let field: Substring
        var value: Substring
        if let colon = line.firstIndex(of: ":") {
            field = line[..<colon]
            value = line[line.index(after: colon)...]
            if value.hasPrefix(" ") { value = value.dropFirst() }
        } else {
            field = Substring(line)
            value = ""
        }
        switch field {
        case "event": event = String(value); sawField = true
        case "data": dataLines.append(String(value)); sawField = true
        case "id": id = String(value); sawField = true
        case "retry": retry = Int(value); sawField = true
        default: break
        }
        return nil
    }
}
