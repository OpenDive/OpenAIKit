// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.
//
// The code samples in README.md, copied here so the compiler checks them.
// Nothing in this file talks to the network: the functions are never called.
// When you change a README sample, change it here too.

import Foundation
import Testing
import OpenAIKit

enum ReadmeSnippets {
    static func quickStart() async throws {
        let client = OpenAI(Configuration(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]))

        let response = try await client.responses.create(
            CreateResponse(model: "gpt-6.2-astra", input: "Write a haiku about Swift.")
        )
        print(response.outputText)
    }

    static func configuration() {
        let client = OpenAI(Configuration(
            apiKey: "sk-...",
            organizationId: "org_...",
            projectId: "proj_...",
            requestOptions: OpenAIRequestOptions(timeoutInterval: 120, maxRetries: 3)
        ))
        // On a server or in a command-line tool, read the standard environment variables.
        let fromEnvironment = OpenAI(.fromEnvironment())
        _ = (client, fromEnvironment)
    }

    static func streaming(client: OpenAI) async throws {
        let request = CreateResponse(model: "gpt-6.2-astra", input: "Tell me a short story.")
        for try await event in client.responses.createStream(request) {
            if let delta = event.outputTextDelta {
                print(delta, terminator: "")
            }
        }
    }

    static func conversation(client: OpenAI) async throws {
        let first = try await client.responses.create(CreateResponse(
            model: "gpt-6.2-astra",
            input: .inputItemList([
                .developer("Answer in one sentence."),
                .user("What is the capital of France?"),
            ])
        ))
        let followUp = try await client.responses.create(CreateResponse(
            model: "gpt-6.2-astra",
            input: "And its population?",
            previousResponseID: first.id
        ))
        print(followUp.outputText)
    }

    static func tools(client: OpenAI) async throws {
        let weather = FunctionTool(
            name: "get_weather",
            description: "Current weather for a city.",
            parameters: [
                "type": "object",
                "properties": ["city": ["type": "string"]],
                "required": ["city"],
                "additionalProperties": false,
            ],
            strict: true
        )
        let response = try await client.responses.create(CreateResponse(
            model: "gpt-6.2-astra",
            input: "What's the weather in Paris?",
            tools: [.function(weather)]
        ))
        struct WeatherArguments: Decodable { let city: String }
        for call in response.functionCalls {
            let arguments = try call.decodeArguments(as: WeatherArguments.self)
            let output = FunctionCallOutputItemParam(output: "18°C and sunny in \(arguments.city)", callID: call.callID)
            let final = try await client.responses.create(CreateResponse(
                model: "gpt-6.2-astra",
                input: .inputItemList([.item(.functionCallOutput(output))]),
                previousResponseID: response.id
            ))
            print(final.outputText)
        }
    }

    static func structuredOutput(client: OpenAI) async throws {
        struct Recipe: Decodable {
            let name: String
            let minutes: Int
        }
        let format = TextResponseFormatJsonSchema(
            name: "recipe",
            schema: [
                "type": "object",
                "properties": ["name": ["type": "string"], "minutes": ["type": "integer"]],
                "required": ["name", "minutes"],
                "additionalProperties": false,
            ],
            strict: true
        )
        let response = try await client.responses.create(CreateResponse(
            model: "gpt-6.2-astra",
            input: "A quick pasta recipe.",
            text: ResponseTextParam(format: .jsonSchema(format))
        ))
        let recipe = try response.decodeOutput(as: Recipe.self)
        print(recipe.name, recipe.minutes)
    }

    static func chatCompletions(client: OpenAI) async throws {
        let completion = try await client.chat.completions.create(CreateChatCompletionRequest(
            model: "gpt-6.2-astra",
            messages: [
                .developer(text: "You are a helpful assistant."),
                .user(text: "Hello!"),
            ]
        ))
        print(completion.firstContent ?? "")

        let stream = client.chat.completions.createStream(CreateChatCompletionRequest(
            model: "gpt-6.2-astra",
            messages: [.user(text: "Count to five.")]
        ))
        for try await chunk in stream {
            print(chunk.contentDelta ?? "", terminator: "")
        }
    }

    static func images(client: OpenAI) async throws {
        let result = try await client.images.generate(CreateImageRequest(
            model: "gpt-image-2",
            prompt: "A watercolor otter reading a book"
        ))
        if let png = result.data?.first?.imageData {
            try png.write(to: URL(fileURLWithPath: "otter.png"))
        }
    }

    static func audio(client: OpenAI) async throws {
        let audioURL = URL(fileURLWithPath: "meeting.m4a")
        let transcript = try await client.audio.transcriptions.create(CreateTranscriptionRequest(
            model: "gpt-4o-transcribe",
            file: try FileUpload(contentsOf: audioURL)
        ))
        if case .json(let json) = transcript {
            print(json.text)
        }

        let speech: Data = try await client.audio.speech.create(CreateSpeechRequest(
            model: "gpt-4o-mini-tts",
            input: "Hello from OpenAIKit!",
            voice: "marin"
        ))
        try speech.write(to: URL(fileURLWithPath: "hello.mp3"))
    }

    static func embeddings(client: OpenAI) async throws {
        let result = try await client.embeddings.create(CreateEmbeddingRequest(
            model: "text-embedding-3-small",
            input: "The quick brown fox"
        ))
        print(result.data.first?.vector?.count ?? 0)
    }

    static func filesAndPaging(client: OpenAI) async throws {
        let upload = FileUpload(data: Data("{\"prompt\":\"hi\"}\n".utf8), filename: "batch.jsonl")
        let file = try await client.files.create(CreateFileRequest(file: upload, purpose: .batch))
        print(file.id)

        for try await file in client.files.listAll(limit: 100) {
            print(file.filename)
        }
    }

    static func errors(client: OpenAI) async {
        do {
            _ = try await client.models.retrieve(model: "does-not-exist")
        } catch let error as OpenAIAPIError {
            print(error.statusCode, error.kind, error.message, error.requestID ?? "")
        } catch {
            print(error.localizedDescription)
        }
    }

    static func webhooks(client: OpenAI, body: Data, headers: [String: String]) throws {
        let event = try client.webhooks.unwrap(payload: body, headers: headers)
        switch event {
        case .responseCompleted(let completed):
            print("Response \(completed.data.id) finished")
        default:
            break
        }
    }

    static func realtime(client: OpenAI) async throws {
        let connection = try client.realtime.connect(model: "gpt-realtime-2")
        defer { connection.close() }
        try await connection.send(json: ["type": "response.create"])
        for try await event in connection.events {
            print(event)
        }
    }

    static func admin() async throws {
        let admin = OpenAI(Configuration(adminAPIKey: ProcessInfo.processInfo.environment["OPENAI_ADMIN_KEY"]))
        for try await project in admin.admin.organization.projects.listAll() {
            print(project.name ?? project.id)
        }
    }

    static func newModelBeforeOpenAIKitListsIt(client: OpenAI) async throws {
        _ = try await client.responses.create(CreateResponse(model: "gpt-7-preview", input: "Hi"))
    }
}

@Test func readmeSnippetsCompile() {
    // Compiling this file is the test.
    _ = ReadmeSnippets.self
}
