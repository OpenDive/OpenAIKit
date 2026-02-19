import Foundation

private struct EmptyContainerContentBody: Encodable {
    init() {}
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ContainersResource {
    func create(parameters: ContainerCreateParameters) async throws -> ContainerObject {
        let url = try client.getServerUrl(path: "/containers")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> ContainerListResponse {
        let url = try client.getServerUrl(path: "/containers")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> ContainerObject {
        let url = try client.getServerUrl(path: "/containers/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/containers/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ContainerFilesResource {
    func create(containerID: String, parameters: ContainerFileCreateParameters) async throws -> ContainerFileObject {
        let url = try client.getServerUrl(path: "/containers/\(containerID)/files")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list(containerID: String) async throws -> ContainerFileListResponse {
        let url = try client.getServerUrl(path: "/containers/\(containerID)/files")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(containerID: String, fileID: String) async throws -> ContainerFileObject {
        let url = try client.getServerUrl(path: "/containers/\(containerID)/files/\(fileID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(containerID: String, fileID: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/containers/\(containerID)/files/\(fileID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ContainerFileContentResource {
    func retrieve(containerID: String, fileID: String) async throws -> Data {
        let url = try client.getServerUrl(path: "/containers/\(containerID)/files/\(fileID)/content")
        return try await OpenAIKitSession.shared.decodeRawUrl(
            with: url,
            configuration: client.configuration,
            body: EmptyContainerContentBody(),
            method: .get
        )
    }
}
