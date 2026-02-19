import Foundation

private struct EmptySkillBody: Encodable {
    init() {}
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension SkillsResource {
    func create(parameters: SkillCreateParameters) async throws -> SkillObject {
        let url = try client.getServerUrl(path: "/skills")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> SkillListResponse {
        let url = try client.getServerUrl(path: "/skills")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> SkillObject {
        let url = try client.getServerUrl(path: "/skills/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func update(id: String, parameters: SkillUpdateParameters) async throws -> SkillObject {
        let url = try client.getServerUrl(path: "/skills/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/skills/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension SkillContentResource {
    func retrieve(skillID: String) async throws -> Data {
        let url = try client.getServerUrl(path: "/skills/\(skillID)/content")
        return try await OpenAIKitSession.shared.decodeRawUrl(
            with: url,
            configuration: client.configuration,
            body: EmptySkillBody(),
            method: .get
        )
    }

    func update(skillID: String, parameters: SkillContentUpdateParameters) async throws -> SkillObject {
        let url = try client.getServerUrl(path: "/skills/\(skillID)/content")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension SkillVersionsResource {
    func list(skillID: String) async throws -> SkillVersionListResponse {
        let url = try client.getServerUrl(path: "/skills/\(skillID)/versions")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(skillID: String, versionID: String) async throws -> SkillVersionObject {
        let url = try client.getServerUrl(path: "/skills/\(skillID)/versions/\(versionID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension SkillVersionContentResource {
    func retrieve(skillID: String, versionID: String) async throws -> Data {
        let url = try client.getServerUrl(path: "/skills/\(skillID)/versions/\(versionID)/content")
        return try await OpenAIKitSession.shared.decodeRawUrl(
            with: url,
            configuration: client.configuration,
            body: EmptySkillBody(),
            method: .get
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension VideosResource {
    func create(parameters: VideoCreateParameters) async throws -> VideoObject {
        let url = try client.getServerUrl(path: "/videos")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> VideoListResponse {
        let url = try client.getServerUrl(path: "/videos")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> VideoObject {
        let url = try client.getServerUrl(path: "/videos/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(id: String) async throws -> VideoObject {
        let url = try client.getServerUrl(path: "/videos/\(id)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}
