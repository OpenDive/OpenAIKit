import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension EvalsResource {
    func create(parameters: EvalCreateParameters) async throws -> EvalObject {
        let url = try client.getServerUrl(path: "/evals")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> EvalListResponse {
        let url = try client.getServerUrl(path: "/evals")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> EvalObject {
        let url = try client.getServerUrl(path: "/evals/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/evals/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension EvalRunsResource {
    func create(evalID: String, parameters: EvalRunCreateParameters) async throws -> EvalRunObject {
        let url = try client.getServerUrl(path: "/evals/\(evalID)/runs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list(evalID: String) async throws -> EvalRunListResponse {
        let url = try client.getServerUrl(path: "/evals/\(evalID)/runs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(evalID: String, runID: String) async throws -> EvalRunObject {
        let url = try client.getServerUrl(path: "/evals/\(evalID)/runs/\(runID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(evalID: String, runID: String) async throws -> EvalRunObject {
        let url = try client.getServerUrl(path: "/evals/\(evalID)/runs/\(runID)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension EvalRunOutputItemsResource {
    func list(evalID: String, runID: String) async throws -> EvalRunOutputItemListResponse {
        let url = try client.getServerUrl(path: "/evals/\(evalID)/runs/\(runID)/output_items")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }
}
