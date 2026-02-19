import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIAudioSpeechTests: XCTestCase {
    func testSpeechParametersEncodeExpectedKeys() throws {
        let params = SpeechParameters(
            input: "Hello world",
            model: "gpt-4o-mini-tts",
            voice: "alloy",
            instructions: "Calm voice",
            responseFormat: "mp3",
            speed: 1.2,
            streamFormat: "audio"
        )

        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["input"] as? String, "Hello world")
        XCTAssertEqual(object["model"] as? String, "gpt-4o-mini-tts")
        XCTAssertEqual(object["voice"] as? String, "alloy")
        XCTAssertEqual(object["instructions"] as? String, "Calm voice")
        XCTAssertEqual(object["response_format"] as? String, "mp3")
        XCTAssertEqual(object["speed"] as? Double, 1.2)
        XCTAssertEqual(object["stream_format"] as? String, "audio")
    }

    func testMockSpeechReturnsData() async throws {
        let mock = MockOpenAI()
        let data = try await mock.createSpeech(parameters: SpeechParameters(input: "test"))
        XCTAssertFalse(data.isEmpty)
    }
}
