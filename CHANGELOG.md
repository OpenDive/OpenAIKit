# Changelog

All notable changes to this project are documented in this file.

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
