// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "OpenAIKit",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "OpenAIKit",
            targets: ["OpenAIKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "OpenAIKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "OpenAIKitTests",
            dependencies: ["OpenAIKit"],
            path: "Tests",
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
