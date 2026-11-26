// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "Probe", platforms: [.macOS(.v14)],
  dependencies: [.package(url: "https://github.com/MacPaw/OpenAI.git", exact: "0.6.1")],
  targets: [.executableTarget(name: "Probe", dependencies: [.product(name: "OpenAI", package: "OpenAI")])])
