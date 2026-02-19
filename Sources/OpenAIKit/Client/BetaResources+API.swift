import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension BetaAssistantsResource {
    func create(parameters: AssistantCreateParameters) async throws -> AssistantObject {
        let url = try client.getServerUrl(path: "/assistants")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> AssistantListResponse {
        let url = try client.getServerUrl(path: "/assistants")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> AssistantObject {
        let url = try client.getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func update(id: String, parameters: AssistantUpdateParameters) async throws -> AssistantObject {
        let url = try client.getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension BetaThreadsResource {
    func create(parameters: ThreadCreateParameters = .init()) async throws -> ThreadObject {
        let url = try client.getServerUrl(path: "/threads")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func retrieve(id: String) async throws -> ThreadObject {
        let url = try client.getServerUrl(path: "/threads/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func update(id: String, parameters: ThreadUpdateParameters) async throws -> ThreadObject {
        let url = try client.getServerUrl(path: "/threads/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/threads/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension BetaThreadRunsResource {
    func create(threadID: String, parameters: ThreadRunCreateParameters) async throws -> ThreadRunObject {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list(threadID: String) async throws -> ThreadRunListResponse {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(threadID: String, runID: String) async throws -> ThreadRunObject {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs/\(runID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(threadID: String, runID: String) async throws -> ThreadRunObject {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs/\(runID)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension BetaThreadRunStepsResource {
    func list(threadID: String, runID: String) async throws -> ThreadRunStepListResponse {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs/\(runID)/steps")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(threadID: String, runID: String, stepID: String) async throws -> ThreadRunStepObject {
        let url = try client.getServerUrl(path: "/threads/\(threadID)/runs/\(runID)/steps/\(stepID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }
}
