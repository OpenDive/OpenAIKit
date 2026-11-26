[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenDive%2FOpenAIKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/OpenDive/OpenAIKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenDive%2FOpenAIKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/OpenDive/OpenAIKit)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://swift.org/package-manager/)
[![CI](https://github.com/OpenDive/OpenAIKit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/OpenDive/OpenAIKit/actions/workflows/ci.yml)
[![Twitter](https://img.shields.io/static/v1?label=Twitter&message=@OpenDiveHQ&color=ca333b)](https://twitter.com/OpenDiveHQ)

<div align="center">
  <a href="https://github.com/OpenDive/OpenAIKit">
     <img src="Resources/Logo.png" alt="OpenAIKit Logo" width="80" height="80">
  </a>
  <h3 align="center">OpenAIKit</h3>
  <p align="center">
  A community-maintained Swift SDK for the OpenAI API.
  <br />
  <br />
     <a href="https://github.com/OpenDive/OpenAIKit/issues">Report Bug</a>
  ·
     <a href="https://github.com/OpenDive/OpenAIKit/issues">Request Feature</a>
 </p>
</div>

## Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Using OpenAIKit](#using-openaikit)
  - [API keys](#api-keys)
  - [Quick start](#quick-start)
  - [Configuration](#configuration)
  - [Responses](#responses)
  - [Streaming](#streaming)
  - [Conversations](#conversations)
  - [Function calling](#function-calling)
  - [Structured outputs](#structured-outputs)
  - [Chat Completions](#chat-completions)
  - [Images](#images)
  - [Audio](#audio)
  - [Embeddings](#embeddings)
  - [Files and pagination](#files-and-pagination)
  - [Realtime](#realtime)
  - [Webhooks](#webhooks)
  - [Administration API](#administration-api)
  - [Errors and retries](#errors-and-retries)
  - [Every other endpoint](#every-other-endpoint)
- [How OpenAIKit stays current](#how-openaikit-stays-current)
- [Migrating to 4.0](#migrating-to-40)
- [Example Projects](#example-projects)
- [Development and Testing](#development-and-testing)
- [License](#license)

## About the Project

**OpenAIKit** is a community-driven Swift SDK for the [OpenAI API](https://developers.openai.com/api/docs). It gives Swift developers typed, `async`/`await` access to every OpenAI endpoint, organized the same way as OpenAI's official Python and JavaScript SDKs.

OpenAIKit 4.0 is generated from OpenAI's published [OpenAPI specification](https://github.com/openai/openai-openapi). Each model, union and enum in the spec becomes a Swift `Codable` type, and each operation becomes a method. When OpenAI ships new endpoints, models or parameters, OpenAIKit regenerates and gets them too.

## Features

- [x] All 388 operations in the OpenAI API (spec 2.3.0), including Responses, Conversations, Chat Completions, Realtime, Live, Audio, Images, Videos, Embeddings, Files, Uploads, Batches, Vector stores, Containers, Skills, Evals, Fine-tuning, Moderations, Webhooks, Agents (beta) and the Administration API.
- [x] 2,294 typed models. Enums are open, so a model ID or event type OpenAI adds later still decodes, and unions keep values they don't recognize as `.unknown` instead of failing.
- [x] Streaming with `AsyncThrowingStream` for Responses, Chat Completions, Audio, Images, Assistants and Agents.
- [x] Typed WebSocket connections for the Realtime and Responses APIs.
- [x] Automatic pagination: every cursor-based list has a `...All` variant that yields items across pages.
- [x] Retries with exponential backoff for connection errors, 408, 409, 429 and 5xx responses, honoring `retry-after`.
- [x] Webhook signature verification (Standard Webhooks) and typed webhook events.
- [x] Multipart uploads for files, audio, images and video.
- [x] Swift 6 language mode with strict concurrency. Every type is `Sendable`.
- [x] No dependencies. Runs on Apple platforms and Linux.
- [x] Tested against every example in OpenAI's spec (769 examples), plus unit tests for transport, streaming, pagination, multipart and webhooks.

## Requirements

| Platforms | Minimum Swift | Installation | Status |
| --- | --- | --- | --- |
| iOS 16+ / macOS 13+ / tvOS 16+ / watchOS 9+ / visionOS 1+ / Linux | 6.2 (Xcode 26) | [Swift Package Manager](#installation) | Tested in CI on Swift 6.2, 6.3 and 6.4 |

## Installation

OpenAIKit is distributed with the [Swift Package Manager](https://swift.org/package-manager/).

**In Xcode:** choose File › Add Package Dependencies…, enter `https://github.com/OpenDive/OpenAIKit.git` and pick "Up to Next Major Version" from `4.0.0`.

**In `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/OpenDive/OpenAIKit.git", from: "4.0.0")
],
targets: [
    .target(name: "YourTarget", dependencies: ["OpenAIKit"])
]
```

## Using OpenAIKit

### API keys

Create an API key on the [API keys page](https://platform.openai.com/api-keys) of the OpenAI platform.

> [!WARNING]
> **Do not ship an API key inside an app.** Anyone can extract it from the binary and use it at your cost. In an app, call OpenAI through your own backend, or use short-lived credentials such as [Realtime client secrets](https://developers.openai.com/api/docs/guides/realtime). Keep keys in environment variables or a secrets manager, keep configuration files that hold them out of source control, and rotate them regularly. [NSHipster's article on secrets](https://nshipster.com/secrets/) covers the options for Swift developers.

### Quick start

```swift
import OpenAIKit

let client = OpenAI(Configuration(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]))

let response = try await client.responses.create(
    CreateResponse(model: "gpt-6.2-astra", input: "Write a haiku about Swift.")
)
print(response.outputText)
```

### Configuration

`Configuration` holds credentials and defaults. `OpenAI` is `Sendable` and cheap to keep around, so create one and share it.

```swift
let client = OpenAI(Configuration(
    apiKey: "sk-...",
    organizationId: "org_...",
    projectId: "proj_...",
    requestOptions: OpenAIRequestOptions(timeoutInterval: 120, maxRetries: 3)
))
// On a server or in a command-line tool, read the standard environment variables.
let fromEnvironment = OpenAI(.fromEnvironment())
```

`Configuration.fromEnvironment()` reads `OPENAI_API_KEY`, `OPENAI_ADMIN_KEY`, `OPENAI_ORG_ID`, `OPENAI_PROJECT_ID`, `OPENAI_WEBHOOK_SECRET` and `OPENAI_BASE_URL`, the same variables the official SDKs use. Every method also takes `options:` to override the timeout, retries, headers or query for a single call.

### Responses

The [Responses API](https://developers.openai.com/api/docs/guides/text) is OpenAI's main API for text, images, tools and multi-turn conversations. `CreateResponse` mirrors the API's parameters, and `outputText` joins the text of every message in the output.

```swift
let response = try await client.responses.create(
    CreateResponse(model: "gpt-6.2-astra", input: "Write a haiku about Swift.")
)
print(response.outputText)
```

Model IDs are open enums: autocomplete lists the models the spec knows, and any string literal works, including models released after this version of OpenAIKit:

```swift
_ = try await client.responses.create(CreateResponse(model: "gpt-7-preview", input: "Hi"))
```

### Streaming

Methods for operations that can stream have a `...Stream` variant that returns an `AsyncThrowingStream` of typed events.

```swift
let request = CreateResponse(model: "gpt-6.2-astra", input: "Tell me a short story.")
for try await event in client.responses.createStream(request) {
    if let delta = event.outputTextDelta {
        print(delta, terminator: "")
    }
}
```

### Conversations

Pass a list of input items, or chain responses with `previousResponseID`:

```swift
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
```

For conversation state that outlives a chain of responses, use `client.conversations`.

### Function calling

```swift
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
```

Built-in tools such as web search, file search, code interpreter, image generation, computer use, shell and MCP are cases of the same `Tool` enum.

### Structured outputs

Give the model a JSON schema and decode its answer into your own type:

```swift
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
```

### Chat Completions

The [Chat Completions API](https://developers.openai.com/api/docs/guides/text?api-mode=chat) is fully supported:

```swift
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
```

### Images

```swift
let result = try await client.images.generate(CreateImageRequest(
    model: "gpt-image-2",
    prompt: "A watercolor otter reading a book"
))
if let png = result.data?.first?.imageData {
    try png.write(to: URL(fileURLWithPath: "otter.png"))
}
```

`client.images.edit(...)` and `client.images.generateStream(...)` cover editing and partial-image streaming. `client.videos` covers video generation.

### Audio

```swift
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
```

Use `client.audio.transcriptions.createText(...)` when you ask for `srt`, `vtt` or `text` output, and `SubtitleCue.parse(_:)` to read SRT or WebVTT.

### Embeddings

```swift
let result = try await client.embeddings.create(CreateEmbeddingRequest(
    model: "text-embedding-3-small",
    input: "The quick brown fox"
))
print(result.data.first?.vector?.count ?? 0)
```

### Files and pagination

`FileUpload` wraps the bytes, file name and content type of a multipart upload. List operations return one page; their `...All` variant walks every page as you iterate.

```swift
let upload = FileUpload(data: Data("{\"prompt\":\"hi\"}\n".utf8), filename: "batch.jsonl")
let file = try await client.files.create(CreateFileRequest(file: upload, purpose: .batch))
print(file.id)

for try await file in client.files.listAll(limit: 100) {
    print(file.filename)
}
```

### Realtime

`client.realtime.connect(...)` opens a WebSocket with typed `RealtimeClientEvent`s and `RealtimeServerEvent`s. `client.responses.connect()` does the same for the Responses WebSocket mode.

```swift
let connection = try client.realtime.connect(model: "gpt-realtime-2")
defer { connection.close() }
try await connection.send(json: ["type": "response.create"])
for try await event in connection.events {
    print(event)
}
```

For browser or mobile clients, mint a short-lived key on your server with `client.realtime.clientSecrets.create(...)`.

### Webhooks

`unwrap` verifies the signature with your endpoint's secret (`Configuration.webhookSecret`, or pass `secret:`) and decodes the event:

```swift
let event = try client.webhooks.unwrap(payload: body, headers: headers)
switch event {
case .responseCompleted(let completed):
    print("Response \(completed.data.id) finished")
default:
    break
}
```

`verifySignature(payload:headers:)` checks a request without decoding it. Pass the raw body exactly as received.

### Administration API

Organization and project management, usage, costs and audit logs live under `client.admin` and use an [admin API key](https://platform.openai.com/settings/organization/admin-keys):

```swift
let admin = OpenAI(Configuration(adminAPIKey: ProcessInfo.processInfo.environment["OPENAI_ADMIN_KEY"]))
for try await project in admin.admin.organization.projects.listAll() {
    print(project.name ?? project.id)
}
```

### Errors and retries

HTTP errors throw `OpenAIAPIError`, with the status code, OpenAI's error message, type, code and param, and the `x-request-id` header. Other failures throw `OpenAIError` (`.missingAPIKey`, `.timeout`, `.connection`, `.decoding`, …).

```swift
do {
    _ = try await client.models.retrieve(model: "does-not-exist")
} catch let error as OpenAIAPIError {
    print(error.statusCode, error.kind, error.message, error.requestID ?? "")
} catch {
    print(error.localizedDescription)
}
```

Connection errors, 408, 409, 429 and 5xx responses are retried twice by default, with exponential backoff and jitter, honoring `retry-after` and `x-should-retry`. Change it with `OpenAIRequestOptions(maxRetries:)`.

### Every other endpoint

Every operation in the API reference has a method, grouped like the official SDKs:

| Area | Namespace |
| --- | --- |
| Responses, input items, input tokens, compaction | `client.responses` |
| Conversations and items | `client.conversations` |
| Chat Completions and stored completions | `client.chat.completions` |
| Legacy completions | `client.completions` |
| Audio: speech, transcriptions, translations, voices, voice consents | `client.audio` |
| Images and videos | `client.images`, `client.videos` |
| Embeddings, moderations | `client.embeddings`, `client.moderations` |
| Files, uploads, batches | `client.files`, `client.uploads`, `client.batches` |
| Vector stores, files and file batches | `client.vectorStores` |
| Containers, skills | `client.containers`, `client.skills` |
| Evals, fine-tuning, graders, checkpoints | `client.evals`, `client.fineTuning` |
| Realtime calls, client secrets, translations | `client.realtime` |
| Live sessions | `client.live` |
| Webhook endpoints and event types | `client.webhooks` |
| Safety, decisions, content provenance | `client.safety`, `client.decisions`, `client.contentProvenanceChecks` |
| Agents, vaults, ChatKit, Assistants, threads (beta) | `client.beta` |
| Organization, projects, users, keys, usage, costs, audit logs | `client.admin.organization` |

Each method's documentation repeats OpenAI's description, its parameters and the HTTP route it calls. Fields the spec does not model yet are reachable through `JSONValue`, and `OpenAIRequestOptions.additionalQuery`/`additionalHeaders` reach any query parameter or header.

## How OpenAIKit stays current

`Sources/OpenAIKit/Generated` is written by [`Generator/generate.py`](Generator/README.md) from a pinned commit of [openai/openai-openapi](https://github.com/openai/openai-openapi). Method names come from [openai-python](https://github.com/openai/openai-python)'s API reference, so `client.beta.threads.runs.submitToolOutputs` here is `client.beta.threads.runs.submit_tool_outputs` there. To pick up a newer spec:

```bash
python3 Generator/generate.py bump && swift test
```

CI regenerates from the pinned spec on every pull request and fails if the committed sources differ.

## Migrating to 4.0

4.0 replaces the hand-written 2.x/3.x API with the generated one. See [MIGRATION.md](MIGRATION.md) for a table of old calls and their 4.0 equivalents. The short version:

- `client.generateChatCompletion(parameters:)` and other flat methods are gone. Use `client.chat.completions.create(...)` and the other namespaced methods.
- Request types are named after the spec: `ChatParameters` → `CreateChatCompletionRequest`, `ImageParameters` → `CreateImageRequest`, and so on.
- Model enums such as `ChatModels` are replaced by open enums that accept any string: `model: "gpt-6.2-astra"`.
- Streaming methods return `AsyncThrowingStream` and end in `Stream`: `client.chat.completions.createStream(...)`.
- HTTP errors throw `OpenAIAPIError`; `OpenAIError` covers everything else.
- Minimum platforms are iOS 16, macOS 13, tvOS 16, watchOS 9 and visionOS 1.

## Example Projects

`Examples/` holds iOS, macOS, tvOS and watchOS sample apps that use the local package. Open one in Xcode, set your API key where the app asks for it, and run it.

## Development and Testing

```bash
swift build
swift test
```

The tests use a mock transport and never reach the network. `Tests/OpenAIKitTests/SpecExampleTests.swift` decodes every example in OpenAI's spec into its generated type and checks that it survives a round trip. `Tests/OpenAIKitTests/ReadmeSnippets.swift` holds the code in this README, so the compiler checks it.

Do not edit `Sources/OpenAIKit/Generated` by hand. Change `Generator/generate.py`, or the hand-written code in `Sources/OpenAIKit/Core` and `Sources/OpenAIKit/Helpers`, then run `python3 Generator/generate.py generate`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

OpenAIKit is released under the MIT license, and any use of OpenAI's API is subject to OpenAI's [usage policies](https://openai.com/policies/usage-policies).

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
