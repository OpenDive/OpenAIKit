// swift-tools-version: 6.2
//
// Benchmarks for OpenAIKit. A separate package, so OpenAIKit itself stays free of dependencies.
// It compares OpenAIKit with MacPaw/OpenAI on identical recorded workloads served from a local replay server.

import PackageDescription

let package = Package(
    name: "OpenAIKitBenchmarks",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/MacPaw/OpenAI.git", exact: "0.6.1"),
    ],
    targets: [
        .executableTarget(
            name: "Bench",
            dependencies: [
                .product(name: "OpenAIKit", package: "OpenAIKit"),
                .product(name: "OpenAI", package: "OpenAI"),
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
