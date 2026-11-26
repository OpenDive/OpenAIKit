// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.
//
// Usage:
//   swift run -c release Bench record                      Record fixtures from the live API (needs OPENAI_API_KEY)
//   swift run -c release Bench run <workload> <sdk> [iterations] [interval-ms]
//   swift run -c release Bench decode <workload> <sdk> [iterations]
//   swift run -c release Bench suite [iterations]          Every workload × SDK, each in a fresh process, as a table

import Foundation
import OpenAI
import OpenAIKit

struct RunResult: Codable {
    var workload: String
    var sdk: SDK
    var mode: String
    var iterations: Int
    /// Wall time per request (JSON) or per whole stream, in milliseconds.
    var wall: Summary
    /// Time from starting the request to the first stream event, in milliseconds.
    var firstEvent: Summary?
    /// Time from the server writing an event to the app receiving it, in microseconds.
    var eventLatency: Summary?
    /// CPU time per iteration, in milliseconds.
    var cpuPerIteration: Double
    var events: Int
    var peakFootprintMB: Double
}

func runWorkload(_ workload: Workload, sdk: SDK, iterations: Int, warmup: Int, intervalMS: Double) async throws -> RunResult {
    let server = try ReplayServer()
    try server.start()
    if workload.kind == .stream {
        server.set(workload.path, .init(body: .events(try Fixtures.events(workload.fixture), interval: intervalMS / 1000)))
    } else {
        server.set(workload.path, .init(body: .json(try Fixtures.data(workload.fixture))))
    }
    let clients = BenchClients(port: server.port)

    for _ in 0..<warmup { _ = try await workload.run(sdk, clients) }

    var wall: [Double] = []
    var first: [Double] = []
    var latency: [Double] = []
    var events = 0
    let cpuStart = cpuTime()
    for _ in 0..<iterations {
        clients.resetArrivals()
        server.resetSentTimes()
        let start = now()
        events = try await workload.run(sdk, clients)
        let end = now()
        wall.append(Double(end - start) / 1e6)
        if workload.kind == .stream {
            let arrivals = clients.takeArrivals()
            if let firstArrival = arrivals.first { first.append(Double(firstArrival - start) / 1e6) }
            if intervalMS > 0 {
                // Events arrive in the order they were sent. Pair the last N of each, because the
                // server also writes events an SDK may not surface (for example `[DONE]`).
                let sent = server.takeSentTimes()
                let pairs = min(sent.count, arrivals.count)
                for i in 0..<pairs {
                    let s = sent[i], a = arrivals[i]
                    if a > s { latency.append(Double(a - s) / 1e3) }
                }
            }
        }
    }
    let cpu = Double(cpuTime() - cpuStart) / 1e6 / Double(iterations)
    return RunResult(
        workload: workload.name, sdk: sdk, mode: "http", iterations: iterations,
        wall: Summary(wall),
        firstEvent: first.isEmpty ? nil : Summary(first),
        eventLatency: latency.isEmpty ? nil : Summary(latency),
        cpuPerIteration: cpu, events: events,
        peakFootprintMB: Double(peakFootprint()) / 1_048_576
    )
}

/// Decoding only: no network, just `JSONDecoder` into each SDK's response type.
func runDecode(_ workload: Workload, sdk: SDK, iterations: Int) throws -> RunResult {
    let data = try Fixtures.data(workload.fixture)
    let decode: () throws -> Void
    switch (workload.name, sdk) {
    case ("models.list", .openaikit): decode = { _ = try JSONDecoder().decode(ListModelsResponse.self, from: data) }
    case ("models.list", .macpaw): decode = { _ = try JSONDecoder().decode(ModelsResult.self, from: data) }
    case ("chat.create", .openaikit): decode = { _ = try JSONDecoder().decode(CreateChatCompletionResponse.self, from: data) }
    case ("chat.create", .macpaw): decode = { _ = try JSONDecoder().decode(ChatResult.self, from: data) }
    case ("responses.create", .openaikit): decode = { _ = try JSONDecoder().decode(OpenAIKit.Response.self, from: data) }
    case ("responses.create", .macpaw): decode = { _ = try JSONDecoder().decode(ResponseObject.self, from: data) }
    case ("embeddings.float", .openaikit): decode = { _ = try JSONDecoder().decode(CreateEmbeddingResponse.self, from: data) }
    case ("embeddings.float", .macpaw): decode = { _ = try JSONDecoder().decode(EmbeddingsResult.self, from: data) }
    default: throw NSError(domain: "bench", code: 1, userInfo: [NSLocalizedDescriptionKey: "No decode benchmark for \(workload.name)"])
    }
    for _ in 0..<5 { try decode() }
    var wall: [Double] = []
    let cpuStart = cpuTime()
    for _ in 0..<iterations {
        let start = now()
        try decode()
        wall.append(Double(now() - start) / 1e6)
    }
    let cpu = Double(cpuTime() - cpuStart) / 1e6 / Double(iterations)
    return RunResult(workload: workload.name, sdk: sdk, mode: "decode", iterations: iterations, wall: Summary(wall),
                     firstEvent: nil, eventLatency: nil, cpuPerIteration: cpu, events: 0,
                     peakFootprintMB: Double(peakFootprint()) / 1_048_576)
}

func printJSON(_ result: RunResult) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    print(String(decoding: try! encoder.encode(result), as: UTF8.self))
}

func runSelf(_ arguments: [String]) throws -> RunResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard let line = String(decoding: data, as: UTF8.self).split(separator: "\n").last else {
        throw NSError(domain: "bench", code: 2, userInfo: [NSLocalizedDescriptionKey: "No output for \(arguments)"])
    }
    return try JSONDecoder().decode(RunResult.self, from: Data(line.utf8))
}

func fmt(_ value: Double, _ digits: Int = 2) -> String { String(format: "%.\(digits)f", value) }

let args = Array(CommandLine.arguments.dropFirst())
func workload(_ name: String) -> Workload {
    guard let w = Workload.all.first(where: { $0.name == name }) else {
        FileHandle.standardError.write(Data("Unknown workload \(name). Known: \(Workload.all.map(\.name).joined(separator: ", "))\n".utf8))
        exit(2)
    }
    return w
}

switch args.first {
case "record":
    try await recordFixtures()
    print("Recorded fixtures in \(Fixtures.directory.path)")
case "run":
    let w = workload(args[1])
    let sdk = SDK(rawValue: args[2])!
    let iterations = args.count > 3 ? Int(args[3])! : 30
    let interval = args.count > 4 ? Double(args[4])! : 0
    printJSON(try await runWorkload(w, sdk: sdk, iterations: iterations, warmup: 3, intervalMS: interval))
case "decode":
    let w = workload(args[1])
    let sdk = SDK(rawValue: args[2])!
    let iterations = args.count > 3 ? Int(args[3])! : 200
    printJSON(try runDecode(w, sdk: sdk, iterations: iterations))
case "parse":
    // Raw parse throughput on the same inputs as the C/C++ shootout (see Benchmarks/README.md).
    let embeddings = try Fixtures.data("embeddings-float.json")
    let events = try Fixtures.events("chat-stream.sse").compactMap { event -> Data? in
        let text = String(decoding: event, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.hasPrefix("data:") else { return nil }
        let payload = text.dropFirst(5).trimmingCharacters(in: .whitespaces)
        return payload == "[DONE]" ? nil : Data(payload.utf8)
    }
    let streamBytes = events.reduce(0) { $0 + $1.count }
    func measure(_ name: String, _ input: String, bytes: Int, iterations: Int, _ body: () throws -> Void) rethrows {
        try body()
        let start = now()
        for _ in 0..<iterations { try body() }
        let seconds = Double(now() - start) / 1e9
        print(String(format: "%-34@ %-11@ %8.1f MB/s  %9.3f ms/iter", name as NSString, input as NSString, Double(bytes) * Double(iterations) / seconds / 1e6, seconds / Double(iterations) * 1e3))
    }
    try measure("Foundation JSONSerialization", "embeddings", bytes: embeddings.count, iterations: 20) { _ = try JSONSerialization.jsonObject(with: embeddings) }
    try measure("JSONDecoder → OpenAIKit types", "embeddings", bytes: embeddings.count, iterations: 20) { _ = try JSONDecoder().decode(CreateEmbeddingResponse.self, from: embeddings) }
    try measure("JSONDecoder → MacPaw types", "embeddings", bytes: embeddings.count, iterations: 20) { _ = try JSONDecoder().decode(EmbeddingsResult.self, from: embeddings) }
    let base64 = try Fixtures.data("embeddings-base64.json")
    try measure("JSONDecoder → OpenAIKit, base64 + floats", "embeddings", bytes: embeddings.count, iterations: 20) {
        let r = try JSONDecoder().decode(CreateEmbeddingResponse.self, from: base64)
        _ = r.data.map { $0.base64Vector ?? [] }
    }
    try measure("Foundation JSONSerialization", "stream", bytes: streamBytes, iterations: 50) { for e in events { _ = try JSONSerialization.jsonObject(with: e) } }
    let decoder = JSONDecoder()
    try measure("JSONDecoder → OpenAIKit types", "stream", bytes: streamBytes, iterations: 50) { for e in events { _ = try decoder.decode(CreateChatCompletionStreamResponse.self, from: e) } }
    try measure("JSONDecoder → MacPaw types", "stream", bytes: streamBytes, iterations: 50) { for e in events { _ = try decoder.decode(ChatStreamResult.self, from: e) } }
case "suite":
    let iterations = args.count > 1 ? Int(args[1])! : 30
    print("| Workload | Mode | SDK | Median ms | p95 ms | CPU ms/iter | First event ms | Event latency µs (p50/p95) | Peak MB |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for w in Workload.all {
        var modes: [[String]] = [["run", w.name, "", String(iterations), "0"]]
        if w.kind == .stream { modes.append(["run", w.name, "", String(max(3, iterations / 6)), "2"]) }
        else { modes.append(["decode", w.name, "", String(iterations * 5)]) }
        for mode in modes {
            for sdk in SDK.allCases {
                var a = mode; a[2] = sdk.rawValue
                let r = try runSelf(a)
                let label = mode[0] == "decode" ? "decode only" : (mode.count > 4 && mode[4] != "0" ? "paced 2 ms/event" : (w.kind == .stream ? "stream, max speed" : "HTTP"))
                let latency = r.eventLatency.map { "\(fmt($0.median, 0)) / \(fmt($0.p95, 0))" } ?? "–"
                print("| \(w.name) | \(label) | \(sdk.rawValue) | \(fmt(r.wall.median, 3)) | \(fmt(r.wall.p95, 3)) | \(fmt(r.cpuPerIteration, 3)) | \(r.firstEvent.map { fmt($0.median, 3) } ?? "–") | \(latency) | \(fmt(r.peakFootprintMB, 1)) |")
            }
        }
    }
default:
    print("Usage: Bench record | run <workload> <sdk> [iterations] [interval-ms] | decode <workload> <sdk> [iterations] | suite [iterations]")
    print("Workloads: \(Workload.all.map(\.name).joined(separator: ", "))")
}
