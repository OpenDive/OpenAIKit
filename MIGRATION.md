# Migrating to OpenAIKit 4.0

OpenAIKit 4.0 is generated from OpenAI's [OpenAPI specification](https://github.com/openai/openai-openapi). Every endpoint, parameter and response field in the current API now has a typed Swift equivalent. The hand-written request and response types of 2.x and 3.x are gone, so most call sites change. This guide maps the old API to the new one.

## Before you start

- **Platforms.** 4.0 needs iOS 16, macOS 13, tvOS 16, watchOS 9 or visionOS 1, and Swift 6.2 (Xcode 26) or later. Linux is supported.
- **Dependency.** Update your requirement to `from: "4.0.0"`.
- **Compile, then fix.** The compiler finds every call site that changed. The tables below give the replacement for each.

## The shape of the 4.0 API

```swift
let client = OpenAI(Configuration(apiKey: apiKey))

// namespace       method   request type named after the spec
client.chat.completions.create(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")]))
```

- **Namespaces match the official SDKs.** `client.responses`, `client.chat.completions`, `client.audio.transcriptions`, `client.vectorStores.files`, `client.admin.organization.projects`, and so on. Method names follow openai-python: `create`, `retrieve`, `update`, `list`, `delete`, `cancel`, plus a few specific verbs.
- **One request value per call**, unlabeled, named after the spec's schema: `create(CreateResponse(...))`. Path parameters are labeled arguments (`retrieve(responseID:)`). Query parameters are labeled arguments with defaults (`list(limit:order:after:)`).
- **Every method takes `options:`**, an `OpenAIRequestOptions` that overrides the timeout, retries, headers or query for that call.
- **Streaming methods end in `Stream`** and return `AsyncThrowingStream<Event, any Error>`. They set `stream: true` for you.
- **Paginated lists have an `...All` variant**, such as `client.files.listAll()`, that walks every page.
- **Enums are open.** `ChatModels`, `ImageModel` and the other closed enums are replaced by `OpenAIStringEnum` structs. They list known values as static members and accept any string literal: `model: "gpt-6.2-astra"`.
- **Unions are enums with associated values**, plus `.unknown(JSONValue)` for values added to the API later. When a union can be a plain string, a string literal works: `input: "Hello"`.

## Client and configuration

| 3.x | 4.0 |
| --- | --- |
| `Configuration(organizationId: org, apiKey: key)` | `Configuration(apiKey: key, organizationId: org)` |
| `Configuration(apiKey:organizationId:projectId:webhookSecret:baseURL:requestOptions:)` | Same labels, plus `adminAPIKey:` for `client.admin` |
| `OpenAIRequestOptions(timeoutInterval: 600, maxRetries: 2, additionalHeaders: [...])` | Same, plus `additionalQuery:`. Every field is optional and falls back to the configuration |
| — | `Configuration.fromEnvironment()` reads `OPENAI_API_KEY` and the other standard variables |
| `OpenAI(config)` | `OpenAI(config)`, or `OpenAI(config, transport: ...)` to supply your own HTTP transport |

## Flat 2.x methods

These were deprecated in 3.x and are removed in 4.0.

| 2.x / 3.x | 4.0 |
| --- | --- |
| `listModels()` | `client.models.list()` |
| `retrieveModel(modelId:)` | `client.models.retrieve(model:)` |
| `deleteModel(model:)` | `client.models.delete(model:)` |
| `generateCompletion(parameters: CompletionParameters)` | `client.completions.create(CreateCompletionRequest(...))` |
| `generateCompletionStreaming(parameters:)` | `client.completions.createStream(...)` |
| `generateChatCompletion(parameters: ChatParameters)` | `client.chat.completions.create(CreateChatCompletionRequest(...))`, or the Responses API: `client.responses.create(CreateResponse(...))` |
| `generateChatCompletionStreaming(parameters:)` | `client.chat.completions.createStream(...)`, or `client.responses.createStream(...)` |
| `createImage(parameters: ImageParameters)` | `client.images.generate(CreateImageRequest(...))` |
| `generateImageEdits(parameters: ImageEditParameters)` | `client.images.edit(CreateImageEditRequest(...))` |
| `generateImageVariations(parameters:)` | `client.images.createVariation(CreateImageVariationRequest(...))` |
| `createEmbeddings(parameters: EmbeddingsParameters)` | `client.embeddings.create(CreateEmbeddingRequest(...))` |
| `createTranscription(parameters: TranscriptionParameters)` | `client.audio.transcriptions.create(CreateTranscriptionRequest(...))`, or `createText(...)` for `srt`, `vtt` and `text` formats |
| `createTranslation(parameters:)` | `client.audio.translations.create(CreateTranslationRequest(...))` |
| `createSpeech(parameters: SpeechParameters)` | `client.audio.speech.create(CreateSpeechRequest(...))` |
| `listFiles()` | `client.files.list()`, or `client.files.listAll()` for every page |
| `uploadFile(parameters: UploadFileParameters)` | `client.files.create(CreateFileRequest(file: FileUpload(...), purpose: .batch))` |
| `retrieveFile(fileId:)` | `client.files.retrieve(fileID:)` |
| `deleteFile(fileId:)` | `client.files.delete(fileID:)` |
| `retrieveFileContent(fileId:)` | `client.files.retrieveContent(fileID:)`, which returns `Data` |
| `checkContentPolicy(parameters: ContentPolicyParameters)` | `client.moderations.create(CreateModerationRequest(...))` |
| `decodeBase64Image(_:)` | `imageObject.imageData`, which returns `Data`. Build a `UIImage` or `NSImage` from it |

## 3.x resource methods

| 3.x | 4.0 |
| --- | --- |
| `client.responses.create(parameters: ResponseCreateParameters(model:input:))` | `client.responses.create(CreateResponse(model:input:))` |
| `client.responses.stream(parameters:)` (yielded `ResponseObject`) | `client.responses.createStream(...)`, which yields typed `ResponseStreamEvent`s. Use `event.outputTextDelta` for text |
| `client.responses.parse(parameters:)` | `client.responses.create(...)`, then `response.decodeOutput(as: MyType.self)` |
| `client.responses.retrieve(id:)` / `delete(id:)` / `cancel(id:)` | `retrieve(responseID:)` / `delete(responseID:)` / `cancel(responseID:)` |
| `client.responses.inputItems.list(responseID:)` | Same, plus `limit:`, `order:`, `after:` and `listAll(responseID:)` |
| `client.responses.inputTokens.create(parameters:)` | `client.responses.inputTokens.count(...)` |
| `client.chat.completions.create(parameters:)` | `client.chat.completions.create(_:)` |
| `client.<resource>.create(parameters: X)` | `client.<resource>.create(X')`, where `X'` is the spec's request type. Search `Sources/*/Generated/Resources` for the method |
| `retrieve(id:)`, `delete(id:)`, `cancel(id:)` | Labeled by the path parameter: `retrieve(vectorStoreID:)`, `cancel(batchID:)`, … |
| `client.realtime.connect(options:)` (a stub) | `client.realtime.connect(model:)`, a real WebSocket with typed events |
| `client.beta.realtime.sessions` | Still there; the GA equivalent is `client.realtime.clientSecrets.create(...)` |

## Types

| 3.x | 4.0 |
| --- | --- |
| `ChatModels`, `CompletionModels`, `ImageModel`, `ContentPolicyModels` | Open enums on each request, such as `ModelIdsShared` and `CreateImageRequest.Model`. Pass a string literal |
| `ChatMessage(role: .user, content: "Hi")` | `ChatCompletionRequestMessage.user(text: "Hi")`, or for Responses input, `InputItem.user("Hi")` |
| `ChatResponse` | `CreateChatCompletionResponse`. `firstContent` returns the first choice's text |
| `ResponseObject` | `Response`. `outputText` joins the text output, `functionCalls` lists tool calls |
| `ImageResponse` | `ImagesResponse` |
| `EmbeddingsResponse` | `CreateEmbeddingResponse`. `embedding.vector` returns `[Double]` |
| `TranscriptionResponse` | `CreateTranscriptionResponse`, a union of the JSON, verbose JSON and diarized JSON forms |
| `File` | `OpenAIFile` |
| `FormData(data:mimeType:fileName:)` | `FileUpload(data:filename:contentType:)`, or `FileUpload(contentsOf: url)` |
| `DeleteObject` | Each delete returns its own type, such as `DeleteFileResponse` |
| `ChatTool`, `Function`, `Parameter` | `ChatCompletionTool` for Chat Completions, `Tool.function(FunctionTool(...))` for Responses. JSON schemas are `JSONObject` literals |
| `SRT.parseSRT(from:)`, `WebVTTCue.parseWebVTT(from:)` | `SubtitleCue.parse(_:)`, which reads both, and `SubtitleCue.srt(_:)` / `webVTT(_:)` to write |
| Arbitrary JSON (`[String: Any]`) | `JSONValue` and `JSONObject`, which are `Codable`, `Hashable`, `Sendable` and literal-expressible |

## Errors

| 3.x | 4.0 |
| --- | --- |
| `OpenAIAPIError.badRequest(payload)`, `.rateLimit(payload)`, … | One struct, `OpenAIAPIError`, with `statusCode`, `kind` (`.badRequest`, `.rateLimit`, …), `message`, `type`, `code`, `param`, `requestID`, `headers` and `body` |
| `OpenAIError.noApiKey` | `OpenAIError.missingAPIKey` (`.missingAdminAPIKey` for `client.admin`) |
| `OpenAIError.invalidUrl`, `.invalidData`, `.noBody`, `.unknownError` | `.invalidURL`, `.decoding(type:underlying:body:)`, `.encoding`, `.connection`, `.timeout`, `.invalidStream` |
| `OpenAIErrorResponse` thrown on decode failure | `OpenAIError.decoding`, which includes the response body |

```swift
do {
    let response = try await client.responses.create(request)
} catch let error as OpenAIAPIError where error.kind == .rateLimit {
    // Back off. OpenAIKit already retried twice.
} catch let error as OpenAIAPIError {
    print(error.statusCode, error.message, error.requestID ?? "")
}
```

Retries changed too. 3.x retried every failure, including 4xx errors. 4.0 retries only connection errors, 408, 409, 429 and 5xx responses, with exponential backoff, and honors `retry-after`, `retry-after-ms` and `x-should-retry`.

## Webhooks

3.x expected a `v1=<hex>` signature in an `openai-signature` header, which is not the scheme OpenAI uses. 4.0 implements [Standard Webhooks](https://www.standardwebhooks.com), as OpenAI's SDKs do: an HMAC-SHA256 of `"{webhook-id}.{webhook-timestamp}.{body}"`, base64-encoded in `webhook-signature`, keyed with the base64 part of your `whsec_...` secret, and a 5-minute replay window.

| 3.x | 4.0 |
| --- | --- |
| `client.webhooks.verifySignature(payload: String, headers:, secret:)` | `verifySignature(payload: Data or String, headers:, secret:, tolerance:)` |
| `client.webhooks.unwrap(payload:headers:as: MyEvent.self)` | `unwrap(payload:headers:)`, which returns the generated `WebhookEvent` union. `unwrap(payload:headers:as:)` still decodes your own type |
| `OpenAIWebhookError.missingWebhookSecret`, `.missingTimestamp`, `.missingSignature`, `.invalidSignature`, `.invalidPayload` | `.missingSecret`, `.missingHeader(name)`, `.invalidTimestamp`, `.timestampTooOld`, `.timestampTooNew`, `.invalidSignature` |

## Testing your code

`OpenAI(configuration, transport:)` accepts any `OpenAIHTTPTransport`, so tests can return canned responses without a network. `Tests/OpenAIKitTests/Support/MockTransport.swift` in this repository is a complete example.
