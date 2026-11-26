// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "Probe", platforms: [.macOS(.v14)],
  dependencies: [.package(path: "../../..")],
  targets: [.executableTarget(name: "Probe", dependencies: [.product(name: "OpenAIKit", package: "OpenAIKit")])])
