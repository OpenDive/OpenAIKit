// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
import Testing
import OpenAIKit
@testable import OpenAIKitCore

@Suite("Generated models")
struct ModelTests {
    @Test func openEnumsAcceptUnknownValues() throws {
        let known = try JSONDecoder().decode(ModelIdsShared.self, from: Data(#""gpt-6.2-astra""#.utf8))
        #expect(known.isKnown)
        let future = try JSONDecoder().decode(ModelIdsShared.self, from: Data(#""gpt-99""#.utf8))
        #expect(future.rawValue == "gpt-99")
        #expect(!future.isKnown)
        let literal: ModelIdsShared = "gpt-99"
        #expect(literal == future)
        #expect(String(decoding: try JSONEncoder().encode(future), as: UTF8.self) == #""gpt-99""#)
    }

    @Test func unionsDecodeByDiscriminatorAndKeepUnknownCases() throws {
        let message = #"{"type":"message","id":"m","status":"completed","role":"assistant","content":[]}"#
        if case .message(let decoded) = try JSONDecoder().decode(OutputItem.self, from: Data(message.utf8)) {
            #expect(decoded.id == "m")
        } else {
            Issue.record("Expected .message")
        }
        let future = #"{"type":"teleport_call","id":"t"}"#
        let decoded = try JSONDecoder().decode(OutputItem.self, from: Data(future.utf8))
        guard case .unknown(let raw) = decoded else {
            Issue.record("Expected .unknown")
            return
        }
        #expect(raw["type"] == "teleport_call")
        #expect(try JSONDecoder().decode(JSONValue.self, from: JSONEncoder().encode(decoded)) == raw, "Unknown values re-encode unchanged")
    }

    @Test func stringUnionsAcceptLiterals() throws {
        let input: InputParam = "Hello"
        #expect(String(decoding: try JSONEncoder().encode(input), as: UTF8.self) == #""Hello""#)
        let items = InputParam.inputItemList([.user("Hi"), .developer("Be brief")])
        let json = try JSONValue(encoding: items)
        #expect(json[0]?["role"] == "user")
        #expect(json[0]?["content"] == "Hi")
        #expect(json[1]?["role"] == "developer")
    }

    @Test func constantFieldsAreFilledIn() throws {
        let message = ChatCompletionRequestMessage.system(text: "Be brief")
        let json = try JSONValue(encoding: message)
        #expect(json == ["role": "system", "content": "Be brief"])
    }

    @Test func jsonValueRoundTrips() throws {
        let value: JSONValue = ["a": [1, 2.5, "x", true, nil], "b": ["c": "d"]]
        let data = try JSONEncoder().encode(value)
        #expect(try JSONDecoder().decode(JSONValue.self, from: data) == value)
        #expect(value["a"]?[1]?.doubleValue == 2.5)
        #expect(value["a"]?[0]?.intValue == 1)
        #expect(value["b"]?["c"]?.stringValue == "d")
        #expect(try JSONValue(parsing: #"{"n":1}"#)["n"] == 1)
    }

    @Test func responseConveniences() throws {
        let response = try JSONDecoder().decode(Response.self, from: Data(responseJSON.utf8))
        #expect(response.outputText == "Hello there")
        #expect(response.functionCalls.map(\.name) == ["lookup"])
        struct Arguments: Decodable { let city: String }
        #expect(try response.functionCalls[0].decodeArguments(as: Arguments.self).city == "Paris")
    }

    @Test func imageDataDecodesBase64() {
        let image = ImageObject(b64JSON: Data([0xFF, 0xD8]).base64EncodedString())
        #expect(image.imageData == Data([0xFF, 0xD8]))
    }

    @Test func fileUploadIsCodableOutsideMultipart() throws {
        let file = FileUpload(data: Data("hi".utf8), filename: "a.txt", contentType: "text/plain")
        #expect(try JSONDecoder().decode(FileUpload.self, from: JSONEncoder().encode(file)) == file)
    }
}

@Suite("Subtitles")
struct SubtitleTests {
    @Test func parsesSRT() {
        let srt = "1\n00:00:00,000 --> 00:00:01,500\nHello\n\n2\n00:00:01,500 --> 00:00:03,000\nTwo\nlines\n"
        let cues = SubtitleCue.parse(srt)
        #expect(cues.count == 2)
        #expect(cues[0].identifier == "1")
        #expect(cues[1].text == "Two\nlines")
        #expect(cues[0].endSeconds == 1.5)
        #expect(SubtitleCue.parse(SubtitleCue.srt(cues)) == cues)
    }

    @Test func parsesWebVTT() {
        let vtt = "WEBVTT\n\n00:00:00.000 --> 00:00:02.000 align:start\nHello\n\n00:01.000 --> 00:02.000\nShort\n"
        let cues = SubtitleCue.parse(vtt)
        #expect(cues.map(\.text) == ["Hello", "Short"])
        #expect(cues[0].end == "00:00:02.000")
        #expect(cues[1].startSeconds == 1)
        #expect(SubtitleCue.webVTT(cues).hasPrefix("WEBVTT\n\n00:00:00.000 --> 00:00:02.000\nHello"))
    }
}
