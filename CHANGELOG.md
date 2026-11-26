# Changelog

All notable changes to this project are documented in this file.

## Unreleased

### Added
- Separate products, so apps link only the APIs they use: `OpenAIKitCore`, `OpenAIKitRealtime` (Realtime and Live), `OpenAIKitBeta` (Agents, Vaults, Assistants, Threads, ChatKit, beta Responses) and `OpenAIKitAdmin` (Administration API). The `OpenAIKit` product still includes everything and re-exports all four modules, so existing code compiles unchanged.
- `OpenAIModel`, the protocol every generated model conforms to.

### Changed
- Much smaller apps. A minimal app making one Responses call and one Chat Completions stream (release build, stripped):
  - **33.4 MB → 11.1 MB** with `OpenAIKitCore`;
  - 33.4 MB → 27.8 MB with `OpenAIKit`.

  Clean release builds take 40–69 s instead of 152 s.
- Generated models no longer each carry a `CodingKeys` enum and a synthesized `==`/`hash(into:)`. They decode with shared string keys, and `OpenAIModel` supplies `Equatable` and `Hashable` once for all types. Equality compares canonical JSON, so `nil` and an omitted field compare equal, as on the wire. It costs more per comparison than synthesized equality, so compare `id`s in hot loops.
- Constant discriminator fields (`type`, `object`) fall back to their known value when a response omits them.

## 4.1.0 - 2026-11-26

### Changed
- Streaming is 2.3× faster and uses about 40% less CPU. In a recorded ~700-word chat stream, delivery dropped from 45.2 ms to 19.9 ms. The server-sent event parser works on bytes, each event is decoded once instead of twice, and streamed bodies arrive in network-sized chunks through a delegate-based `URLSession` instead of byte by byte.
- `ServerSentEvent` exposes the raw `dataBytes`; `data` is now computed from them.

### Added
- End-to-end tests that replay API traffic recorded from the live API through a local server, so requests go through a real `URLSession`. They cover JSON endpoints, both stream types, pacing, early exit, cancellation, connection reuse and concurrent requests.
- Live API tests that run only when `OPENAI_API_KEY` is set: Responses, streaming, tool calling, embeddings and a Realtime session.

## 4.0.1 - 2026-11-25

### Fixed
- Requests to a custom `baseURL`, such as your own proxy, no longer need an API key. Without one, no `Authorization` header is sent, so the server can add OpenAI's key and the app can authenticate with its own headers ([#37](https://github.com/OpenDive/OpenAIKit/issues/37)). A missing key against `api.openai.com` still throws `OpenAIError.missingAPIKey`.

## 4.0.0 - 2026-11-25

OpenAIKit 4.0 is generated from OpenAI's OpenAPI specification (openai/openai-openapi `abe304d`, spec version 2.3.0) and covers the whole API. See [MIGRATION.md](MIGRATION.md) to upgrade from 3.x.

### Breaking Changes
- Replaced the hand-written request and response types with generated ones named after the spec (`ChatParameters` → `CreateChatCompletionRequest`, `ResponseCreateParameters` → `CreateResponse`, `ImageParameters` → `CreateImageRequest`, …).
- Removed the flat 2.x methods on `OpenAI` (`generateChatCompletion`, `createImage`, `listModels`, …) and the `OpenAIProtocol` protocol. Use the namespaced methods (`client.chat.completions.create`, `client.images.generate`, `client.models.list`, …).
- Methods take the request body as one unlabeled argument and path parameters as labeled arguments: `retrieve(responseID:)` instead of `retrieve(id:)`.
- Streaming methods end in `Stream` and yield typed events: `client.responses.createStream(...)` yields `ResponseStreamEvent`.
- Replaced closed model enums (`ChatModels`, `ImageModel`, …) with open `OpenAIStringEnum` types that accept any string.
- HTTP errors now throw the `OpenAIAPIError` struct (status, kind, message, type, code, param, request ID). `OpenAIError` covers client-side failures.
- Webhook verification now implements Standard Webhooks (`webhook-id`, `webhook-timestamp`, `webhook-signature: v1,<base64>`, `whsec_` secrets, 5-minute tolerance), the scheme OpenAI uses. The 3.x check expected a different header format.
- Raised the minimum platforms to iOS 16, macOS 13, tvOS 16, watchOS 9 and visionOS 1. Removed the `Package@swift-5.x.swift` manifests.
- Replaced `SRT` and `WebVTTCue` with `SubtitleCue`.

### Added
- All 388 operations and 2,294 schemas in the spec, including Agents, Vaults, Live, Safety, Decisions, Content provenance, Voices and voice consents, webhook endpoints, video characters/edits/extensions, fine-tuning graders and checkpoint permissions, vector store search, stored chat completions, and the Administration API (`client.admin`, using `Configuration.adminAPIKey`).
- Unions decode by discriminator and keep unrecognized values as `.unknown(JSONValue)`, so new event and item types don't break decoding.
- `...All` auto-paging variants for 84 list operations (`client.files.listAll()`).
- Typed WebSocket connections: `client.realtime.connect(model:)`, `client.realtime.connectTranslation(model:)`, `client.responses.connect()`.
- `WebhookEvent`, a typed union of every webhook OpenAI sends, returned by `client.webhooks.unwrap(payload:headers:)`.
- `Configuration.fromEnvironment()`, `OpenAIRequestOptions.additionalQuery`, and per-call `options:` on every method.
- Pluggable `OpenAIHTTPTransport`, with `URLSessionTransport` as the default.
- Conveniences: `Response.outputText`, `functionCalls`, `decodeOutput(as:)`, `ResponseStreamEvent.outputTextDelta`, `InputItem.user(_:)`, `ChatCompletionRequestMessage.user(text:)`, `FunctionToolCall.decodeArguments(as:)`, `Embedding.vector`, `ImageObject.imageData`.
- `JSONValue` for arbitrary JSON, and `FileUpload` for multipart files.
- Linux support, with a portable SHA-256/HMAC for webhook verification where CryptoKit is unavailable.
- `Generator/generate.py`, which regenerates the package from a pinned spec, and `bump`, which pins the newest one.
- Cancelling the Swift `Task` that made a request cancels the HTTP request, and the call throws `CancellationError`.

### Changed
- Retries now apply only to connection errors, 408, 409, 429 and 5xx, with exponential backoff (0.5–8 s, jitter) and support for `retry-after`, `retry-after-ms` and `x-should-retry`. 3.x retried every error, including 4xx.
- Server-sent events are parsed incrementally per the WHATWG rules, including `[DONE]`, `event:` names and errors sent inside the stream.
- Multipart bodies use bracket notation for arrays and objects (`image[]`, `chunking_strategy[type]`), as the API expects.
- Beta resources send their `OpenAI-Beta` header (`assistants=v2`, `agents=v1`, `chatkit_beta=v1`).
- The `User-Agent` header identifies OpenAIKit and its version.

### CI and Docs
- CI builds and tests on macOS with Xcode 26.3, 26.6 and 27.2 (Swift 6.2, 6.3, 6.4); on iOS, tvOS, watchOS and visionOS simulators; and on Linux with Swift 6.2, 6.3 and 6.4. A separate job fails when the generated sources don't match the pinned spec.
- Tests use Swift Testing. They decode every example in the spec (769 examples) and round-trip each one, and cover requests, multipart, retries, errors, streaming, pagination and webhooks.
- Rewrote the README for 4.0, with demo recordings and an image gallery made with OpenAIKit. Its code samples are compiled by the test suite. Added MIGRATION.md, Generator/README.md and AGENTS.md.
- Ported the example apps to 4.0. The iOS app has a Showcase section (streaming chat, image studio, Realtime console) and reads `OPENAI_API_KEY` from the environment.

## 3.0.0 - 2026-02-19

### Breaking Changes
- Introduced a modular resource-first client surface (for example `client.chat.completions`, `client.responses`, `client.uploads`) as the primary 3.x API.
- Migrated core request payloads from manual dictionaries to strongly typed `Encodable` request models.
- Updated package language mode to Swift 6.2 with Swift 6 concurrency checks enabled.

### Added
- Added Responses resources (`create`, `stream`, `parse`, `retrieve`, `cancel`, `delete`) and typed input item/token helpers.
- Added Realtime resources with calls, client secret support, and connection manager abstractions.
- Added Uploads resources with upload parts and upload completion flows.
- Added Conversations resources with nested conversation items APIs.
- Added Containers resources with nested files/content APIs.
- Added Evals resources with runs and output items APIs.
- Added Skills resources (including versions and content APIs) and Videos resources.
- Added webhook signature verification and typed `unwrap` helpers.
- Added/expanded resource coverage for Audio speech, Vector stores, Batches, Fine-tuning jobs, and Beta assistants/threads.

### Changed
- Improved transport configuration with typed request options (timeouts, retries, additional headers) and typed status error mapping.
- Expanded `Configuration` to include project ID, webhook secret, base URL, and richer request options.
- Modernized chat parameter modeling to cover current chat completion fields (tools, response format, token controls, etc.).

### Concurrency and Hardening
- Hardened streaming and transport internals for Swift 6.2 concurrency compatibility.
- Added `Sendable` conformances and safe type constraints across streamed/response model surfaces.

### Docs and Tests
- Added migration guidance for 2.x -> 3.x in the README.
- Added comprehensive step-based tests for each newly introduced resource area and compatibility behavior.
