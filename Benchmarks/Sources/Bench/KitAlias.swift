// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.
import Foundation
import OpenAIKit

typealias KitClient = OpenAI

func makeKitClient(port: UInt16) -> KitClient {
    OpenAI(Configuration(apiKey: "sk-bench", baseURL: URL(string: "http://127.0.0.1:\(port)/v1")!, requestOptions: OpenAIRequestOptions(maxRetries: 0)))
}
