import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension BatchesResource {
    func create(parameters: BatchCreateParameters) async throws -> BatchObject {
        let url = try client.getServerUrl(path: "/batches")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> BatchListResponse {
        let url = try client.getServerUrl(path: "/batches")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> BatchObject {
        let url = try client.getServerUrl(path: "/batches/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(id: String) async throws -> BatchObject {
        let url = try client.getServerUrl(path: "/batches/\(id)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}
