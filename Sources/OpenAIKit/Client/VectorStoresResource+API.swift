import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension VectorStoresResource {
    func create(parameters: VectorStoreCreateParameters) async throws -> VectorStoreObject {
        let url = try client.getServerUrl(path: "/vector_stores")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> VectorStoreListResponse {
        let url = try client.getServerUrl(path: "/vector_stores")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> VectorStoreObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func update(id: String, parameters: VectorStoreUpdateParameters) async throws -> VectorStoreObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension VectorStoreFilesResource {
    func create(vectorStoreID: String, parameters: VectorStoreFileCreateParameters) async throws -> VectorStoreFileObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/files")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list(vectorStoreID: String) async throws -> VectorStoreFileListResponse {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/files")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(vectorStoreID: String, fileID: String) async throws -> VectorStoreFileObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/files/\(fileID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(vectorStoreID: String, fileID: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/files/\(fileID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension VectorStoreFileBatchesResource {
    func create(vectorStoreID: String, parameters: VectorStoreFileBatchCreateParameters) async throws -> VectorStoreFileBatchObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/file_batches")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list(vectorStoreID: String) async throws -> VectorStoreFileBatchListResponse {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/file_batches")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(vectorStoreID: String, fileBatchID: String) async throws -> VectorStoreFileBatchObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/file_batches/\(fileBatchID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(vectorStoreID: String, fileBatchID: String) async throws -> VectorStoreFileBatchObject {
        let url = try client.getServerUrl(path: "/vector_stores/\(vectorStoreID)/file_batches/\(fileBatchID)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}
