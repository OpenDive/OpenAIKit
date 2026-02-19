import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension AudioSpeechResource {
    func create(parameters: SpeechParameters) async throws -> Data {
        let url = try client.getServerUrl(path: "/audio/speech")
        return try await OpenAIKitSession.shared.decodeRawUrl(
            with: url,
            configuration: client.configuration,
            body: parameters,
            acceptHeader: "application/octet-stream"
        )
    }
}
