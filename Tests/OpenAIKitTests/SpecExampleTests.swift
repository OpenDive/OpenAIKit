// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Testing
@testable import OpenAIKit

/// One example from the OpenAPI spec and the generated type it should decode into.
struct SpecExample: Decodable, Sendable, CustomTestStringConvertible {
    let name: String
    let type: String
    let kind: String
    let wrapped: Bool?
    let body: String

    var testDescription: String { name }

    static let all: [SpecExample] = {
        let data = try! Data(contentsOf: Fixtures.url("spec-examples.json"))
        return try! JSONDecoder().decode([SpecExample].self, from: data)
    }()
}

@Suite("OpenAPI spec examples")
struct SpecExampleTests {
    @Test("Every example decodes into its generated type and survives a round trip", arguments: SpecExample.all)
    func decodes(_ example: SpecExample) throws {
        let decode = try #require(SpecExampleDecoders.all[example.type], "No decoder for \(example.type)")
        switch example.kind {
        case "json":
            #expect(try decode(Data(example.body.utf8)), "Round trip changed the value")
        case "sse":
            var parser = ServerSentEventParser()
            let events = parser.feed(Data(example.body.utf8)) + parser.finish()
            #expect(!events.isEmpty)
            for event in events where event.data != "[DONE]" && !event.data.isEmpty {
                var payload = Data(event.data.utf8)
                if example.wrapped == true, let name = event.event {
                    let inner = try JSONDecoder().decode(JSONValue.self, from: payload)
                    payload = try JSONEncoder().encode(JSONValue.object(["event": .string(name), "data": inner]))
                }
                #expect(try decode(payload), "Round trip changed \(event.event ?? "event")")
            }
        default:
            Issue.record("Unknown example kind \(example.kind)")
        }
    }

    @Test func coversTheSpec() {
        #expect(SpecExample.all.count > 700)
        #expect(OpenAIGeneratedMetadata.operationCount == 388)
    }
}
