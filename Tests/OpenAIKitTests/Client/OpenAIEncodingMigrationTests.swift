import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIEncodingMigrationTests: XCTestCase {
    private func jsonObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("Expected JSON dictionary")
            return [:]
        }
        return object
    }

    func testCompletionParametersEncodeSnakeCaseKeys() throws {
        let params = CompletionParameters(
            model: .textCurie001,
            prompt: ["hello"],
            maxTokens: 32,
            temperature: 0.5,
            topP: 0.9,
            numberOfCompletions: 2,
            stream: true
        )

        let encoded = try jsonObject(params)
        XCTAssertEqual(encoded["model"] as? String, "text-curie-001")
        XCTAssertEqual(encoded["max_tokens"] as? Int, 32)
        XCTAssertEqual(encoded["top_p"] as? Double, 0.9)
        XCTAssertEqual(encoded["n"] as? Int, 2)
        XCTAssertEqual(encoded["stream"] as? Bool, true)
    }

    func testChatParametersEncodeModelAndFunctions() throws {
        let parameters = Parameters(
            type: "object",
            properties: [
                "location": ParameterDetail(type: "string")
            ],
            required: ["location"]
        )
        let function = Function(
            name: "lookup_weather",
            description: "Find weather for city",
            parameters: parameters
        )
        let tool = ChatTool(function: function)
        let params = ChatParameters(
            model: .gpt4,
            customModel: "gpt-5.2",
            messages: [ChatMessage(role: .user, content: "hello")],
            functionCall: "auto",
            functions: [function],
            tools: [tool],
            toolChoice: "required",
            responseFormat: ChatResponseFormat(type: .jsonObject),
            seed: 7,
            maxCompletionTokens: 128,
            parallelToolCalls: true,
            logprobs: true,
            topLogprobs: 2
        )

        let encoded = try jsonObject(params)
        XCTAssertEqual(encoded["model"] as? String, "gpt-5.2")
        XCTAssertEqual(encoded["function_call"] as? String, "auto")
        XCTAssertNotNil(encoded["functions"])
        XCTAssertEqual(encoded["tool_choice"] as? String, "required")
        XCTAssertEqual(encoded["seed"] as? Int, 7)
        XCTAssertEqual(encoded["max_completion_tokens"] as? Int, 128)
        XCTAssertEqual(encoded["parallel_tool_calls"] as? Bool, true)
        XCTAssertEqual(encoded["logprobs"] as? Bool, true)
        XCTAssertEqual(encoded["top_logprobs"] as? Int, 2)
        XCTAssertNotNil(encoded["tools"])
        XCTAssertNotNil(encoded["response_format"])
    }

    func testImageParametersEncodeExpectedKeyNames() throws {
        let params = ImageParameters(
            prompt: "A test image",
            numberofImages: 1,
            resolution: .large,
            quality: .hd,
            style: .vivid,
            model: .dalle3,
            responseFormat: .url
        )

        let encoded = try jsonObject(params)
        XCTAssertEqual(encoded["prompt"] as? String, "A test image")
        XCTAssertEqual(encoded["n"] as? Int, 1)
        XCTAssertEqual(encoded["size"] as? String, "1024x1024")
        XCTAssertEqual(encoded["response_format"] as? String, "url")
        XCTAssertEqual(encoded["model"] as? String, "dall-e-3")
    }

    func testEmbeddingsParametersEncodeDirectly() throws {
        let params = EmbeddingsParameters(model: "text-embedding-3-small", input: "hello", user: "u1")
        let encoded = try jsonObject(params)

        XCTAssertEqual(encoded["model"] as? String, "text-embedding-3-small")
        XCTAssertEqual(encoded["input"] as? String, "hello")
        XCTAssertEqual(encoded["user"] as? String, "u1")
    }
}
