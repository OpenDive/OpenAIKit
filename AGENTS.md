# OpenAIKit

A Swift package for the OpenAI API. Most of the code is generated from OpenAI's OpenAPI spec.

## Layout

- `Sources/OpenAIKit/Generated/` — **generated, never edit by hand.** `Models/` has one Codable type per spec schema; `Resources/` has one struct per API namespace with one method per operation.
- `Sources/OpenAIKit/Core/` — hand-written runtime: `OpenAI` client, `Configuration`, `OpenAIRequest`, transport and retries, server-sent events, pagination, `JSONValue`, `FileUpload`, errors, webhook verification.
- `Sources/OpenAIKit/Helpers/` — hand-written conveniences on generated types (`Response.outputText`, message builders, WebSockets, subtitles).
- `Generator/generate.py` — the generator (Python 3.9+, standard library only). `Generator/config.json` pins the spec commit and its SHA-256; `Generator/sdk-naming.json` maps each operation to openai-python's namespace and method name.
- `Tests/OpenAIKitTests/` — Swift Testing. `Generated/` and `Fixtures/spec-examples.json` are written by the generator. `ReadmeSnippets.swift` mirrors every code block in `README.md`.

## Commands

```bash
swift build
swift test
python3 Generator/generate.py generate   # after changing the generator
python3 Generator/generate.py check      # what CI runs: fails if generated files are stale
python3 Generator/generate.py bump       # pin the newest spec and naming, then regenerate
```

## Rules

- To change generated code, change `Generator/generate.py` (or `config.json`) and regenerate. Commit the generator change and the regenerated files together.
- Keep the package free of dependencies and building on Linux (`#if canImport(FoundationNetworking)`, no CryptoKit without a fallback).
- Swift 6 language mode; every public type is `Sendable`.
- When you change a README code sample, change `Tests/OpenAIKitTests/ReadmeSnippets.swift` the same way.
- Tests never touch the network: use `MockTransport` in `Tests/OpenAIKitTests/Support`.
