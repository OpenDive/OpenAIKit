import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ResponsesResource {
    func create(parameters: ResponseCreateParameters) async throws -> ResponseObject {
        let url = try client.getServerUrl(path: "/responses")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func stream(parameters: ResponseCreateParameters) throws -> AsyncThrowingStream<ResponseObject, Error> {
        let url = try client.getServerUrl(path: "/responses")
        var streamingParameters = parameters
        streamingParameters.stream = true
        return try OpenAIKitSession.shared.streamData(
            with: url,
            configuration: client.configuration,
            body: streamingParameters
        )
    }

    func parse(parameters: ResponseCreateParameters) async throws -> ResponseObject {
        try await create(parameters: parameters)
    }

    func retrieve(id: String) async throws -> ResponseObject {
        let url = try client.getServerUrl(path: "/responses/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/responses/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }

    func cancel(id: String) async throws -> ResponseObject {
        let url = try client.getServerUrl(path: "/responses/\(id)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ResponseInputItemsResource {
    func list(responseID: String) async throws -> ResponseInputItemListResponse {
        let url = try client.getServerUrl(path: "/responses/\(responseID)/input_items")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ResponseInputTokensResource {
    func create(parameters: ResponseInputTokensParameters) async throws -> ResponseInputTokenCount {
        let url = try client.getServerUrl(path: "/responses/input_tokens")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }
}
