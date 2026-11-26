// swift-tools-version: 6.2
//
//  Package.swift
//  OpenAIKit
//
//  Copyright (c) 2023-2026 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import PackageDescription

let swiftSettings: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "OpenAIKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        // Everything. Simplest to start with.
        .library(name: "OpenAIKit", targets: ["OpenAIKit"]),
        // Pick only what you use to keep your app small. Core covers Responses, Chat Completions,
        // Conversations, Audio, Images, Videos, Embeddings, Files, Uploads, Batches, Vector stores,
        // Containers, Skills, Evals, Fine-tuning, Moderations, Models and Webhooks.
        .library(name: "OpenAIKitCore", targets: ["OpenAIKitCore"]),
        .library(name: "OpenAIKitRealtime", targets: ["OpenAIKitRealtime"]),
        .library(name: "OpenAIKitBeta", targets: ["OpenAIKitBeta"]),
        .library(name: "OpenAIKitAdmin", targets: ["OpenAIKitAdmin"]),
    ],
    targets: [
        .target(name: "OpenAIKitCore", swiftSettings: swiftSettings),
        .target(name: "OpenAIKitRealtime", dependencies: ["OpenAIKitCore"], swiftSettings: swiftSettings),
        .target(name: "OpenAIKitBeta", dependencies: ["OpenAIKitCore"], swiftSettings: swiftSettings),
        .target(name: "OpenAIKitAdmin", dependencies: ["OpenAIKitCore"], swiftSettings: swiftSettings),
        .target(
            name: "OpenAIKit",
            dependencies: ["OpenAIKitCore", "OpenAIKitRealtime", "OpenAIKitBeta", "OpenAIKitAdmin"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "OpenAIKitTests",
            dependencies: ["OpenAIKit"],
            path: "Tests/OpenAIKitTests",
            resources: [.copy("Fixtures")],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
