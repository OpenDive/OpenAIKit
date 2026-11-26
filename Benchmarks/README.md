# OpenAIKit benchmarks

A separate Swift package that measures OpenAIKit, and compares it with [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) 0.6.1, on identical workloads.

## How it works

- **Recorded fixtures.** `Fixtures/` holds real API responses recorded with `Bench record`: a models list, a Chat Completion, a Response, 64 embeddings (float and base64), and roughly 700-word Chat Completions and Responses streams.
- **Local replay server.** `ReplayServer` is a small HTTP/1.1 server on 127.0.0.1, built on Network.framework. Both SDKs reach it through a real `URLSession` over real sockets, so the numbers cover everything an app pays for except the internet: connection handling, body delivery, SSE framing and JSON decoding. Streams are written one event per TCP write, as OpenAI does.
- **Fair setup.** Every workload × SDK pair runs in a fresh process, with three warm-up iterations, then N measured ones.

## Metrics

| Column | Meaning |
| --- | --- |
| Median / p95 ms | Wall time per request, or per complete stream |
| CPU ms/iter | User + system CPU time per iteration. On a phone, this is battery |
| First event ms | Time from starting a stream to receiving its first event |
| Event latency µs | In paced mode (one event every 2 ms), time from the server writing an event to the app receiving it, decoded. This is SDK overhead per token |
| Peak MB | Peak physical footprint of the process |
| decode only | `JSONDecoder` into each SDK's response type, with no network |

## Running

```bash
cd Benchmarks
swift build -c release
.build/release/Bench suite 30                       # everything, as a Markdown table
.build/release/Bench run chat.stream openaikit 50   # one workload, as JSON
.build/release/Bench decode embeddings.float macpaw
python3 profile.py chat.stream openaikit 300        # Time Profiler trace and hot-function summary
OPENAI_API_KEY=sk-... .build/release/Bench record   # re-record fixtures from the live API
```

## Binary size

`SizeProbe/measure.sh` builds three tiny release executables that make the same calls (no SDK, OpenAIKit, MacPaw), strips them, and prints their sizes and build times.
