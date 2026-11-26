# Contributing to OpenAIKit

We welcome bug reports, fixes, features and documentation, and we are glad to add maintainers.

## How the code is organized

Most of OpenAIKit is generated from OpenAI's OpenAPI specification. Before you change anything, find out which part you are touching:

| Folder | What it holds | How to change it |
| --- | --- | --- |
| `Sources/OpenAIKit/Generated` | Models and resource methods | **Do not edit.** Change `Generator/generate.py` and regenerate |
| `Sources/OpenAIKit/Core` | Client, transport, retries, streaming, pagination, webhooks | Edit directly |
| `Sources/OpenAIKit/Helpers` | Conveniences on generated types, WebSockets, subtitles | Edit directly |
| `Generator` | The generator and its pinned inputs | See [Generator/README.md](Generator/README.md) |
| `Tests/OpenAIKitTests` | Swift Testing tests | Edit directly, except `Generated/` and `Fixtures/spec-examples.json` |

If an endpoint is missing or a field has the wrong type, the fix almost always belongs in the generator, or OpenAI's spec has changed and needs `python3 Generator/generate.py bump`.

## Workflow

We use [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow): every change goes through a pull request.

1. Fork the repository and create a branch from `main`.
2. Make your change. Add tests for new behavior.
3. If you change the public API, update `README.md`, and update `Tests/OpenAIKitTests/ReadmeSnippets.swift` to match any README code you change.
4. Run the checks CI runs:

   ```bash
   swift build
   swift test
   python3 Generator/generate.py check
   ```

5. Open the pull request.

Tests must not reach the network. Use `MockTransport` in `Tests/OpenAIKitTests/Support`.

## Style

- Four spaces for indentation, as in the existing code.
- Swift 6 language mode. Public types are `Sendable`.
- No third-party dependencies, and keep Linux building (`#if canImport(FoundationNetworking)`).
- Document public API with `///` comments.

## Reporting bugs

Use [GitHub issues](https://github.com/OpenDive/OpenAIKit/issues/new/choose). A helpful report has:

- A short summary
- Steps to reproduce, with sample code if you can
- What you expected and what happened
- The OpenAIKit version, platform and Swift version
- For API errors, the `requestID` of the `OpenAIAPIError` (never your API key)

## License

By contributing, you agree that your contributions are licensed under the project's MIT License.
