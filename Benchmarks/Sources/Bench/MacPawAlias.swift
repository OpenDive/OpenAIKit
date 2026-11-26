// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.
// MacPaw's module and client class are both named `OpenAI`; this file imports only MacPaw so the name is unambiguous.
import OpenAI

typealias MacPawClient = OpenAI

func makeMacPawClient(port: UInt16) -> MacPawClient {
    OpenAI(configuration: .init(token: "sk-bench", host: "127.0.0.1", port: Int(port), scheme: "http", timeoutInterval: 600))
}
