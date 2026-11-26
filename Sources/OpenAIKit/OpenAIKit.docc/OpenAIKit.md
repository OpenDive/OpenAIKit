# ``OpenAIKit``

A Swift SDK for the whole OpenAI API, generated from OpenAI's OpenAPI specification.

## Overview

Create one ``OpenAI`` client and call operations through namespaces that match OpenAI's official SDKs:

```swift
import OpenAIKit

let client = OpenAI(Configuration(apiKey: "sk-..."))

let response = try await client.responses.create(
    CreateResponse(model: "gpt-6.2-astra", input: "Write a haiku about Swift.")
)
print(response.outputText)
```

Every request and response type is a generated `Codable`, `Hashable`, `Sendable` value named after its schema in the spec, such as ``CreateResponse`` and ``Response``. Enums conform to ``OpenAIStringEnum`` and accept values the spec doesn't list yet. Unions decode values they don't recognize as `.unknown(JSONValue)`.

Don't ship an API key inside an app. Call OpenAI from your own server, or use short-lived Realtime client secrets.

## Topics

### Essentials

- ``OpenAI``
- ``Configuration``
- ``OpenAIRequestOptions``

### Errors

- ``OpenAIAPIError``
- ``OpenAIError``
- ``OpenAIWebhookError``

### Responses API

- ``CreateResponse``
- ``Response``
- ``ResponseStreamEvent``
- ``InputItem``
- ``Tool``

### Chat Completions

- ``CreateChatCompletionRequest``
- ``CreateChatCompletionResponse``
- ``CreateChatCompletionStreamResponse``
- ``ChatCompletionRequestMessage``

### Streaming, pagination and WebSockets

- ``ServerSentEvent``
- ``ServerSentEventParser``
- ``OpenAIAutoPagingSequence``
- ``OpenAIPage``
- ``OpenAIWebSocket``
- ``RealtimeConnection``
- ``ResponsesConnection``

### Values

- ``JSONValue``
- ``JSONObject``
- ``FileUpload``
- ``OpenAIStringEnum``
- ``SubtitleCue``

### Webhooks

- ``WebhookEvent``

### Customizing transport

- ``OpenAIHTTPTransport``
- ``URLSessionTransport``
- ``OpenAIRequest``
- ``MultipartPart``

### Generated sources

- ``OpenAIGeneratedMetadata``
