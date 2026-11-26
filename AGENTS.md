# OpenAIKit: guide for coding agents

OpenAIKit is a Swift package for the whole OpenAI API. Almost all of it is generated from OpenAI's OpenAPI spec. This file covers two jobs: **using** OpenAIKit in someone's app, and **working on** this repository.

## Using OpenAIKit in an app

Add `.package(url: "https://github.com/OpenDive/OpenAIKit.git", from: "4.0.0")` and depend on the `OpenAIKit` product. It needs Swift 6.2+, and iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1 or Linux.

```swift
import OpenAIKit

let client = OpenAI(.fromEnvironment())   // reads OPENAI_API_KEY and friends
let response = try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hello"))
print(response.outputText)
```

How to find the right call:

- **Namespaces and method names follow openai-python**, camel-cased. `client.audio.transcriptions.create` here is the same call there; `submit_tool_outputs` there is `submitToolOutputs` here. `Generator/sdk-naming.json` maps every HTTP route to its namespace and method.
- **Find a method** by searching `Sources/OpenAIKit/Generated/Resources/` for the HTTP route, for example `` `POST /responses` ``. Every method's doc comment starts with its route.
- **Request and response types are named after the spec's schemas**, such as `CreateResponse`, `Response`, `CreateChatCompletionRequest` and `CreateImageRequest`. Find one with `grep -rn "public struct CreateResponse:" Sources/OpenAIKit/Generated/Models`. Inline types are nested: `CreateResponse.Truncation`.
- **Arguments:** the body is the unlabeled first argument; path parameters are labeled (`retrieve(responseID:)`); query parameters are labeled with defaults; `options:` comes last.
- **Streaming:** use the `…Stream` variant (`createStream`), which returns an `AsyncThrowingStream` of typed events. `event.outputTextDelta` gives Responses text.
- **Lists:** use the `…All` variant (`listAll`) to walk every page.
- **Enums are open structs**, so pass string literals freely (`model: "gpt-6.2-astra"`). **Unions** are enums with associated values plus `.unknown(JSONValue)`; a union with a string case accepts a string literal (`input: "Hi"`).
- **Hand-written conveniences** are in `Sources/OpenAIKit/Helpers/Conveniences.swift`: `Response.outputText`, `functionCalls`, `decodeOutput(as:)`, `InputItem.user(_:)`, `ChatCompletionRequestMessage.user(text:)`, `FunctionToolCall.decodeArguments(as:)`, `Embedding.vector`, `ImageObject.imageData`.
- **Realtime:** `try client.realtime.connect(model:)` returns an `OpenAIWebSocket` with `send(_:)`, `send(json:)` and `events`.
- **Errors:** HTTP failures throw `OpenAIAPIError` (`statusCode`, `kind`, `message`, `requestID`); others throw `OpenAIError`. Cancelling the Swift `Task` cancels the request.
- **Never put an API key in app code** or commit one. Read it from the environment or a backend.

`README.md` has a compiled example for every major feature, and `Examples/iOS_Example/iOS_Example/Showcase.swift` is a complete SwiftUI app using chat streaming, image generation and Realtime.

## Working on this repository

### Layout

| Path | What it is | Edit it? |
| --- | --- | --- |
| `Sources/OpenAIKit/Generated/` | Models (one Codable type per spec schema) and Resources (one struct per namespace, one method per operation) | **Never by hand.** Change the generator and regenerate |
| `Sources/OpenAIKit/Core/` | Client, `Configuration`, `OpenAIRequest`, transport with retries and cancellation, server-sent events, pagination, `JSONValue`, `FileUpload`, errors, webhook verification | Yes |
| `Sources/OpenAIKit/Helpers/` | Conveniences on generated types, WebSockets, subtitles | Yes |
| `Generator/generate.py` | The generator, Python 3.9+ with the standard library only. `config.json` pins the spec commit and SHA-256; `sdk-naming.json` holds the names | Yes, then regenerate |
| `Tests/OpenAIKitTests/` | Swift Testing. `Generated/` and `Fixtures/spec-examples.json` are written by the generator | Yes, except those two |
| `Tests/OpenAIKitTests/ReadmeSnippets.swift` | Every code block in `README.md`, compiled | Keep in sync with the README |
| `Examples/` | iOS, macOS, tvOS and watchOS apps using the local package | Yes |
| `Resources/readme/` | README banner, demo GIFs and gallery images | Yes |

### Commands

```bash
swift build
swift test                                   # never touches the network
python3 Generator/generate.py generate       # after changing the generator
python3 Generator/generate.py check          # what CI runs: fails if generated files are stale
python3 Generator/generate.py bump           # pin the newest spec and naming, regenerate, then run swift test
xcodebuild -project Examples/iOS_Example/iOS_Example.xcodeproj -scheme iOS_Example \
  -destination 'generic/platform=iOS Simulator' build
```

### Rules

- **Generated code:** fix the generator, regenerate, and commit the generator change and the regenerated files together.
- **No dependencies.** Keep Linux building: guard networking with `#if canImport(FoundationNetworking)`, and don't use CryptoKit without the portable fallback in `Core/Webhooks.swift`.
- **Swift 6 language mode.** Every public type is `Sendable`. Keep the build free of warnings.
- **Tests:** never touch the network. Use `MockTransport` in `Tests/OpenAIKitTests/Support/`. Add a test for each behavior change.
- **README:** when you change a code sample, change `ReadmeSnippets.swift` the same way, and the reverse.
- **Public API changes:** update `README.md`, `MIGRATION.md` if they break 3.x users, and `CHANGELOG.md`.
- **Secrets:** never commit API keys. The example apps read `OPENAI_API_KEY` from the environment; keep it that way.

### Before you open a pull request

1. `swift build` has no warnings, and `swift test` passes.
2. `python3 Generator/generate.py check` passes.
3. If you touched `Examples/`, the app you changed builds with `xcodebuild`.
4. If you touched Linux-sensitive code (`Core/Transport.swift`, `Core/Webhooks.swift`, `Helpers/WebSocket.swift`), run `docker run --rm -v "$PWD":/src -w /src swift:6.2-noble swift test`.
5. Follow `.github/pull_request_template.md`.
