# OpenAIKit 4.1 performance plan

Measured on 2026-11-25 on an Apple silicon Mac (macOS 27.2, Xcode 27.1, Swift 6.4, release builds) with the harness in this folder. Both SDKs replay the same recorded API responses through a real `URLSession` against a local server. See [README.md](README.md) for the method.

## Where 4.0.0 stood

Requests that return JSON were at parity with MacPaw/OpenAI 0.6.1. Both decode with `JSONDecoder`, and both spend the same time in `URLSession`. Streaming was the gap:

| Workload (4.0.0) | OpenAIKit | MacPaw |
| --- | --- | --- |
| Chat stream, max speed | 45.2 ms, 103 ms CPU | 21.5 ms, 67 ms CPU |
| Responses stream, max speed | 32.6 ms, 91 ms CPU | 21.1 ms, 62 ms CPU |
| Chat stream, paced 2 ms/token: SDK latency per token (p50) | 512 µs | 120–390 µs |

Instruments (Time Profiler, `profile.py`) showed three causes, all in OpenAIKit's own code:

1. **Every event was parsed twice.** It was decoded into `JSONValue` to check for an `error` key (about 13% of samples), then decoded again into its type.
2. **The Apple transport read the body one byte at a time** through `URLSession.AsyncBytes` and yielded once per line.
3. **The SSE parser built a `String` per line** and converted event data from `String` back to `Data` before decoding.

## Fixed on this branch

- Byte-level SSE parser: one pass over each chunk, no `String` for event data (`ServerSentEvent.dataBytes`).
- One decode per event. A prefix check for `{"error"` replaces the `JSONValue` pre-pass, and wrapped Assistants events are spliced as bytes.
- Streaming transport: one delegate-based `URLSession` per transport routes each task's chunks as they arrive, on Apple platforms and Linux.

| Workload | 4.0.0 | This branch | MacPaw |
| --- | --- | --- | --- |
| Chat stream, max speed | 45.2 ms | **19.9 ms** (2.3× faster) | 17.9 ms |
| Chat stream CPU | 103 ms | **59 ms** | 59 ms |
| Responses stream, max speed | 32.6 ms | **21.1 ms** | 22.4 ms |
| Responses stream CPU | 91 ms | **60 ms** | 66 ms |
| Chat stream, paced: per-token latency p50 / p95 | 512 / 973 µs | **382 / 748 µs** | 391 / 786 µs |
| Responses stream, paced: per-token latency p50 / p95 | 452 / 881 µs | **230 / 648 µs** | 464 / 1029 µs |

Streaming is now at parity with MacPaw or ahead of it. Paced runs vary by about ±15% between runs; the chat figures are the mean of three alternating runs.

## JSON parsing: what native code could buy

Raw parse throughput on our recorded payloads: a 1.9 MB float-embeddings response, and 876 chat-stream events parsed one at a time.

| Parser | Embeddings | Stream events |
| --- | --- | --- |
| yyjson 0.12 (C), DOM | **1,266 MB/s** | **1,919 MB/s** |
| facil.io cstl (C), FIOBJ | 795 MB/s | 202 MB/s |
| Glaze (C++23), generic DOM | 727 MB/s | 563 MB/s |
| Foundation `JSONSerialization` | 56 MB/s | 116 MB/s |
| `JSONDecoder` into OpenAIKit types | 94 MB/s | 50 MB/s |
| `JSONDecoder` into MacPaw types | 96 MB/s | 48 MB/s |

`JSONDecoder`'s generic `Codable` machinery is now the main cost in every workload, and it costs both SDKs the same. yyjson parses the same bytes 13–38× faster. Building Swift values afterwards gives some of that back, so the end-to-end win would be smaller than the raw ratio.

Glaze's headline numbers come from compile-time reflection into C++ structs. Using that would mean mirroring 2,294 schemas in C++ plus Swift–C++ interop. Into a generic DOM, the fair comparison here, it's slower than yyjson. facil.io is slow on many small documents, which is the streaming case.

## Proposed for 4.1, by measured impact

1. **Binary size: split products and generate leaner conformances.** An app that uses OpenAIKit 4.0 grows by 33 MB, vs 9.4 MB for MacPaw. See [Binary size](#binary-size) below. This matters more to app developers than any speedup on this list.
2. **Base64 embeddings by default.** Request `encoding_format: "base64"` and unpack the floats, as the official Python SDK does. Measured: **0.53 ms instead of 19.9 ms to decode 64 × 1536 embeddings (38× faster)**, and **3.6× less data over the network** (0.53 MB instead of 1.89 MB). This is pure Swift, invisible to callers, and you can opt out with `encodingFormat: .float`.
3. **Generated fast decoders: Glaze's idea in Swift.** The generator already knows every type, so it can emit specialized decoders for the hot types: stream events, `Response`, chat chunks and embeddings. They would read fields straight from a fast tokenizer and skip `Codable`'s generic containers. `Codable` stays as the fallback and public API. Prototype first on `CreateChatCompletionStreamResponse` and `ResponseStreamEvent`.
4. **Optional native tokenizer.** Only if (3) is still tokenizer-bound: vendor yyjson (MIT, about 2 files) as a C target that isn't a product, imported with `internal import`, so it stays off OpenAIKit's public interface. C rather than Objective-C, because there's no message-dispatch or bridging cost and it works on Linux. Keep `JSONDecoder` as the fallback.
5. **First-event latency.** Our first event arrives about 6 ms after the request starts, vs about 3.5 ms for MacPaw. Profile request setup: building the request, encoding the body and the first delegate hop.
6. **Instruments integration.** Add `OSSignposter` intervals for each request phase (build, wait, first byte, body, decode) and an event per stream token, so the OpenAIKit timeline shows in Instruments' Points of Interest. It's free when no trace is recording. Optionally expose `URLSessionTaskMetrics` (DNS, TLS, time to first byte) through a per-request metrics callback.
7. **Connection prewarming.** `client.prewarm()` would open the TLS connection before the first request. Measure its effect on time to first token against the live API.
8. **Faster `JSONValue` decoding.** It still decodes `.unknown` cases and free-form fields by trying each type in turn. Order the attempts better, or build it from a tokenizer.

## Not doing

- **Networking or cryptography in C.** `URLSession` costs every SDK the same, and replacing it means reimplementing HTTP/2, TLS, proxies and App Transport Security as unsafe code that parses untrusted network data. Webhook HMAC is one call per webhook, and CryptoKit is already hardware-accelerated and constant-time.
- **Objective-C.** It adds message-dispatch and bridging cost and doesn't exist on Linux.

## Binary size

A minimal command-line tool makes one Responses call and one Chat stream, built in release mode and stripped (`strip -x`). Reproduce it with `Benchmarks/SizeProbe/measure.sh`.

| Probe binary | Stripped size | Clean release build |
| --- | --- | --- |
| No SDK (Foundation only) | 0.06 MB | 8 s |
| MacPaw 0.6.1 (with swift-openapi-runtime) | 9.4 MB | – |
| **OpenAIKit 4.0.0** | **33.4 MB** (14.9 MB of machine code) | 156 s |
| OpenAIKit 4.0.0 without synthesized `Hashable` on generated types | 28.0 MB (−16%) | 110 s (−30%) |

**Size is OpenAIKit's real weakness.** Dead-code stripping can't remove generated types, because their `Codable` and `Hashable` conformance records keep them alive. So all 2,294 types and their synthesized conformances ship in every app, whether it uses one endpoint or all 388. MacPaw covers far fewer endpoints, which is why its binary is smaller.

Levers, in order of expected size reduction:

1. **Split products.** For example, `OpenAIKit` (Responses, Chat, Embeddings, Images, Audio, Files, Models and the other core APIs), `OpenAIKitRealtime` (Realtime and Live), `OpenAIKitBeta` (Agents, Assistants, ChatKit) and `OpenAIKitAdmin` (125 Administration operations). Apps pay only for the modules they import. The generator already knows each operation's namespace, and shared schemas go in the core module. This should give the largest reduction for a typical app, and the namespaces don't change.
2. **One direction per type.** 518 schemas are only ever sent and 1,083 only ever received; 605 go both ways and 88 are unused. Generating `Encodable` for request-only types and `Decodable` for response-only types removes about half the `Codable` code for 70% of types. It's API-visible for apps that re-encode responses, so it could keep `Codable` on response types and drop only `Decodable` on request types.
3. **Drop synthesized `Hashable` (measured: −16% size, −30% build time).** Keep `Equatable` if tests and users need comparisons, or make `Hashable` opt-in through a generator flag. Source-breaking for apps that put generated types in `Set`s or use them as dictionary keys, so it belongs in a minor version only with a deprecation note, or in 5.0.
4. **Drop schemas no operation reaches** (88), except the WebSocket event types, which are reached through `connect`.
5. **Compact decoding.** Table-driven coding keys shared across types, instead of a synthesized `CodingKeys` enum per type. This combines well with the generated fast decoders in item 3 of the main list.

Target for 4.1: under 12 MB for a Responses-and-Chat app.
