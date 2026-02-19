import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ConversationsResource {
    func create(parameters: ConversationCreateParameters = .init()) async throws -> ConversationObject {
        let url = try client.getServerUrl(path: "/conversations")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> ConversationListResponse {
        let url = try client.getServerUrl(path: "/conversations")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> ConversationObject {
        let url = try client.getServerUrl(path: "/conversations/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(id: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/conversations/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension ConversationItemsResource {
    func list(conversationID: String) async throws -> ConversationItemListResponse {
        let url = try client.getServerUrl(path: "/conversations/\(conversationID)/items")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func create(
        conversationID: String,
        parameters: ConversationItemCreateParameters
    ) async throws -> ConversationItemObject {
        let url = try client.getServerUrl(path: "/conversations/\(conversationID)/items")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func retrieve(conversationID: String, itemID: String) async throws -> ConversationItemObject {
        let url = try client.getServerUrl(path: "/conversations/\(conversationID)/items/\(itemID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func delete(conversationID: String, itemID: String) async throws -> DeleteObject {
        let url = try client.getServerUrl(path: "/conversations/\(conversationID)/items/\(itemID)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .delete,
            bodyRequired: false
        )
    }
}
