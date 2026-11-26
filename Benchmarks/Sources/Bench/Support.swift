// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import OpenAIKit

// MARK: Timing and resources

@inline(__always) func now() -> UInt64 { DispatchTime.now().uptimeNanoseconds }

/// User + system CPU time of this process, in nanoseconds.
func cpuTime() -> UInt64 {
    var usage = rusage()
    getrusage(RUSAGE_SELF, &usage)
    let user = UInt64(usage.ru_utime.tv_sec) * 1_000_000_000 + UInt64(usage.ru_utime.tv_usec) * 1_000
    let system = UInt64(usage.ru_stime.tv_sec) * 1_000_000_000 + UInt64(usage.ru_stime.tv_usec) * 1_000
    return user + system
}

/// Peak physical footprint of this process, in bytes.
func peakFootprint() -> UInt64 {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
    }
    return result == KERN_SUCCESS ? UInt64(info.ledger_phys_footprint_peak) : 0
}

/// Bytes currently allocated by malloc.
func mallocInUse() -> Int {
    var stats = malloc_statistics_t()
    malloc_zone_statistics(nil, &stats)
    return Int(stats.size_in_use)
}

struct Summary: Codable {
    var count: Int
    var mean: Double
    var median: Double
    var p95: Double
    var min: Double
    var max: Double

    init(_ values: [Double]) {
        let sorted = values.sorted()
        count = sorted.count
        mean = sorted.isEmpty ? 0 : sorted.reduce(0, +) / Double(sorted.count)
        func percentile(_ p: Double) -> Double {
            guard !sorted.isEmpty else { return 0 }
            let index = Swift.min(sorted.count - 1, Swift.max(0, Int((Double(sorted.count - 1) * p).rounded())))
            return sorted[index]
        }
        median = percentile(0.5)
        p95 = percentile(0.95)
        self.min = sorted.first ?? 0
        self.max = sorted.last ?? 0
    }
}

// MARK: Fixtures

enum Fixtures {
    static var directory: URL {
        if let override = ProcessInfo.processInfo.environment["BENCH_FIXTURES"] {
            return URL(fileURLWithPath: override)
        }
        // Benchmarks/Sources/Bench/Support.swift -> Benchmarks/Fixtures
        return URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Fixtures")
    }

    static func data(_ name: String) throws -> Data {
        try Data(contentsOf: directory.appendingPathComponent(name))
    }

    /// Splits a recorded SSE body into events, each including its trailing blank line.
    static func events(_ name: String) throws -> [Data] {
        let text = String(decoding: try data(name), as: UTF8.self).replacingOccurrences(of: "\r\n", with: "\n")
        return text.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.map { Data(($0 + "\n\n").utf8) }
    }
}

// MARK: Recording live traffic

/// Wraps the default transport and writes every response body to disk.
final class RecordingTransport: OpenAIHTTPTransport, @unchecked Sendable {
    let base = URLSessionTransport()
    let destination: URL
    var name = "unnamed"
    private let lock = NSLock()

    init(destination: URL) {
        self.destination = destination
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await base.send(request)
        try data.write(to: destination.appendingPathComponent(name))
        return (data, response)
    }

    func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        let (chunks, response) = try await base.stream(request)
        let file = destination.appendingPathComponent(name)
        let tee = AsyncThrowingStream<Data, any Error> { continuation in
            Task {
                var all = Data()
                do {
                    for try await chunk in chunks {
                        all.append(chunk)
                        continuation.yield(chunk)
                    }
                    try all.write(to: file)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        return (tee, response)
    }
}

func recordFixtures() async throws {
    let transport = RecordingTransport(destination: Fixtures.directory)
    try FileManager.default.createDirectory(at: Fixtures.directory, withIntermediateDirectories: true)
    let client = OpenAI(.fromEnvironment(), transport: transport)
    let model: ModelIdsResponses = "gpt-6.2-astra"

    transport.name = "models.json"
    _ = try await client.models.list()

    transport.name = "responses-create.json"
    _ = try await client.responses.create(CreateResponse(model: model, input: "Explain how Swift concurrency works in about 250 words."))

    transport.name = "responses-stream.sse"
    for try await _ in client.responses.createStream(CreateResponse(model: model, input: "Write a 700-word short story about a robot who learns Swift.")) {}

    transport.name = "chat-create.json"
    _ = try await client.chat.completions.create(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Explain how Swift concurrency works in about 250 words.")]))

    transport.name = "chat-stream.sse"
    for try await _ in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Write a 700-word short story about a robot who learns Swift.")])) {}

    let inputs = (1...64).map { "Benchmark sentence number \($0) about Swift, concurrency and the OpenAI API." }
    transport.name = "embeddings-float.json"
    _ = try await client.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: .strings(inputs)))

    transport.name = "embeddings-base64.json"
    _ = try await client.embeddings.create(CreateEmbeddingRequest(model: "text-embedding-3-small", input: .strings(inputs), encodingFormat: .base64))
}
