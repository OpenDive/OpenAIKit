import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension UploadsResource {
    func create(parameters: UploadCreateParameters) async throws -> UploadObject {
        let url = try client.getServerUrl(path: "/uploads")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func retrieve(id: String) async throws -> UploadObject {
        let url = try client.getServerUrl(path: "/uploads/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(id: String) async throws -> UploadObject {
        let url = try client.getServerUrl(path: "/uploads/\(id)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }

    func complete(id: String, parameters: UploadCompleteParameters) async throws -> UploadObject {
        let url = try client.getServerUrl(path: "/uploads/\(id)/complete")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension UploadPartsResource {
    func create(uploadID: String, parameters: UploadPartCreateParameters) async throws -> UploadPartObject {
        let url = try client.getServerUrl(path: "/uploads/\(uploadID)/parts")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }
}
