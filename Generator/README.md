# OpenAIKit generator

`generate.py` turns OpenAI's OpenAPI document into the Swift sources in `Sources/OpenAIKit/Generated`, plus the spec-example tests in `Tests/OpenAIKitTests/Generated` and `Tests/OpenAIKitTests/Fixtures/spec-examples.json`. It needs Python 3.9 or later and nothing else.

## Commands

| Command | What it does |
| --- | --- |
| `python3 Generator/generate.py generate` | Regenerates every generated file from the pinned spec. Run it after you change the generator. |
| `python3 Generator/generate.py check` | Regenerates in memory and fails if any committed file differs. CI runs this. |
| `python3 Generator/generate.py bump` | Pins the newest commit of openai/openai-openapi and openai-python, refreshes the naming table, and regenerates. Run `swift test` afterwards and review the diff. |
| `python3 Generator/generate.py fetch` | Downloads the pinned spec into `Generator/.cache` (gitignored) and verifies its SHA-256. The other commands do this when needed. |
| `python3 Generator/generate.py naming` | Rebuilds `sdk-naming.json` from openai-python's `api.md` files at the pinned commit. |

Set `GITHUB_TOKEN` if `bump` hits GitHub's rate limit.

## Inputs

- **`config.json`** pins the spec (`spec.commit`, `spec.sha256`) and the openai-python commit used for naming. It also lists the `OpenAI-Beta` header for each beta namespace, and operations whose stream switch is not a `stream` field (`streamOverrides`).
- **`sdk-naming.json`** maps `"<verb> <path>"` to openai-python's namespace and method, for example `"post /responses": ["responses", "create"]`. Swift names are the camel-cased versions: `client.responses.create`. An operation missing from the table gets a name derived from its path.

## How schemas map to Swift

| Spec | Swift |
| --- | --- |
| Object with `properties` (and `allOf` of objects) | `struct` with `Codable, Hashable, Sendable`, a memberwise `init`, and `CodingKeys` for snake_case names |
| Required, non-nullable property | Non-optional property |
| Optional or nullable property | Optional property, `nil` by default, omitted when encoding |
| Property with a single constant value (`type: "message"`) | `String` property preset to that value and left out of `init` |
| String `enum`, or `anyOf` of strings and enums | Open enum: a struct conforming to `OpenAIStringEnum`, with a static member per known value |
| `oneOf` / `anyOf` of different shapes | `indirect enum` with one case per variant and `.unknown(JSONValue)`. Discriminated unions decode by their discriminator; others try variants in order. Unions with a string case are `ExpressibleByStringLiteral` |
| `additionalProperties` map | `[String: T]` |
| Free-form object or `{}` | `JSONObject` or `JSONValue` |
| `format: binary` | `FileUpload` |
| `format: int64` | `Int64` |
| Inline schemas | Nested types named after their property, such as `CreateResponse.Truncation` |

Spec names that would shadow Swift, Foundation or SwiftUI types get an `Object` suffix: `Error` → `ErrorObject`, `Image` → `ImageObject`.

The spec marks some properties required that its own examples leave out. The generator walks every example in the spec and makes such properties optional, so real responses decode. It also treats the `first_id`/`last_id` list cursors as optional, because the API returns `null` for empty pages.

## How operations map to Swift

Each operation becomes a method on its namespace's resource struct:

- **Path parameters** are labeled `String` arguments (`retrieve(responseID:)`).
- **The request body** is one unlabeled argument. JSON bodies are encoded with `JSONEncoder`. Multipart bodies use bracket notation: `image[]` for arrays, `chunking_strategy[type]` for objects.
- **Query parameters** are labeled arguments with defaults. Arrays encode as `name[]=a&name[]=b`.
- **Header parameters** (`OpenAI-Beta` betas, `Idempotency-Key`) are labeled arguments.
- **Responses**: JSON decodes into the generated type; binary content returns `Data`; SDP and plain text return `String`; no content returns nothing.
- **Streaming** operations get a `...Stream` variant that sets `stream: true` and returns `AsyncThrowingStream` of the event type. Operations that only stream return the stream directly. Operations that can also answer in plain text (transcriptions) get a `...Text` variant.
- **Cursor-paginated lists** get a `...All` variant returning `OpenAIAutoPagingSequence`.
- **Administration operations** authenticate with `Configuration.adminAPIKey`.
- **Deprecated operations** are marked `@available(*, deprecated)`.

## Changing the generator

1. Edit `generate.py`.
2. Run `python3 Generator/generate.py generate`, then `swift build` and `swift test`.
3. Commit the generator change together with the regenerated files.
