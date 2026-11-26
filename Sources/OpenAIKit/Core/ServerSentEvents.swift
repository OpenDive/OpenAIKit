// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// One server-sent event.
public struct ServerSentEvent: Sendable, Hashable {
    public var event: String?
    /// The `data` field's raw bytes. Multiple `data:` lines are joined with `\n`.
    public var dataBytes: Data
    public var id: String?
    public var retry: Int?

    /// The `data` field as text.
    public var data: String {
        String(decoding: dataBytes, as: UTF8.self)
    }

    public init(event: String? = nil, data: String, id: String? = nil, retry: Int? = nil) {
        self.init(event: event, dataBytes: Data(data.utf8), id: id, retry: retry)
    }

    public init(event: String? = nil, dataBytes: Data, id: String? = nil, retry: Int? = nil) {
        self.event = event
        self.dataBytes = dataBytes
        self.id = id
        self.retry = retry
    }
}

/// Incremental parser for the `text/event-stream` format.
///
/// Feed it chunks of bytes as they arrive; it returns each complete event.
/// Follows the WHATWG rules: lines end with LF, CR or CRLF, a blank line ends an event,
/// lines starting with `:` are comments, and repeated `data:` lines join with newlines.
///
/// The parser works on bytes: it scans each chunk once, copies only the bytes of a line that
/// spans two chunks, and never builds a `String` for event data.
public struct ServerSentEventParser: Sendable {
    private static let lf: UInt8 = 0x0A
    private static let cr: UInt8 = 0x0D
    private static let colon: UInt8 = 0x3A
    private static let space: UInt8 = 0x20

    /// The start of a line whose end has not arrived yet.
    private var partialLine: [UInt8] = []
    private var event: String?
    private var data: [UInt8] = []
    private var hasData = false
    private var id: String?
    private var retry: Int?
    private var sawField = false
    /// The previous chunk ended with CR, so a leading LF in the next chunk belongs to it.
    private var pendingCR = false

    public init() {}

    public mutating func feed(_ chunk: Data) -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        chunk.withUnsafeBytes { raw in
            let bytes = raw.bindMemory(to: UInt8.self)
            let count = bytes.count
            var index = 0
            if pendingCR, count > 0, bytes[0] == Self.lf {
                index = 1
            }
            pendingCR = false
            var lineStart = index
            while index < count {
                let byte = bytes[index]
                if byte == Self.lf || byte == Self.cr {
                    let line = UnsafeBufferPointer(rebasing: bytes[lineStart..<index])
                    if partialLine.isEmpty {
                        processLine(line, into: &events)
                    } else {
                        partialLine.append(contentsOf: line)
                        let joined = partialLine
                        partialLine.removeAll(keepingCapacity: true)
                        joined.withUnsafeBufferPointer { processLine($0, into: &events) }
                    }
                    if byte == Self.cr {
                        if index + 1 < count {
                            if bytes[index + 1] == Self.lf { index += 1 }
                        } else {
                            pendingCR = true
                        }
                    }
                    lineStart = index + 1
                }
                index += 1
            }
            if lineStart < count {
                partialLine.append(contentsOf: UnsafeBufferPointer(rebasing: bytes[lineStart..<count]))
            }
        }
        return events
    }

    /// Flushes an event that was not followed by a blank line before the stream ended.
    public mutating func finish() -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        if !partialLine.isEmpty {
            let line = partialLine
            partialLine.removeAll()
            line.withUnsafeBufferPointer { processLine($0, into: &events) }
        }
        dispatch(into: &events)
        return events
    }

    private mutating func dispatch(into events: inout [ServerSentEvent]) {
        if sawField {
            events.append(ServerSentEvent(event: event, dataBytes: Data(data), id: id, retry: retry))
        }
        event = nil
        data.removeAll(keepingCapacity: true)
        hasData = false
        retry = nil
        sawField = false
    }

    private mutating func processLine(_ line: UnsafeBufferPointer<UInt8>, into events: inout [ServerSentEvent]) {
        guard let first = line.first else {
            dispatch(into: &events)
            return
        }
        if first == Self.colon { return }
        let colonIndex = line.firstIndex(of: Self.colon) ?? line.count
        let name = UnsafeBufferPointer(rebasing: line[0..<colonIndex])
        var valueStart = Swift.min(colonIndex + 1, line.count)
        if valueStart < line.count, line[valueStart] == Self.space { valueStart += 1 }
        let value = UnsafeBufferPointer(rebasing: line[valueStart..<line.count])

        if Self.equals(name, "data") {
            if hasData { data.append(Self.lf) }
            data.append(contentsOf: value)
            hasData = true
            sawField = true
        } else if Self.equals(name, "event") {
            event = String(decoding: value, as: UTF8.self)
            sawField = true
        } else if Self.equals(name, "id") {
            id = String(decoding: value, as: UTF8.self)
            sawField = true
        } else if Self.equals(name, "retry") {
            retry = Int(String(decoding: value, as: UTF8.self))
            sawField = true
        }
    }

    private static func equals(_ bytes: UnsafeBufferPointer<UInt8>, _ name: StaticString) -> Bool {
        guard bytes.count == name.utf8CodeUnitCount else { return false }
        let expected = UnsafeBufferPointer(start: name.utf8Start, count: name.utf8CodeUnitCount)
        return bytes.elementsEqual(expected)
    }
}
