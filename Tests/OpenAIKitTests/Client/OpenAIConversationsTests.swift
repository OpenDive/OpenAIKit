import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAIConversationsTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testConversationItemCreateParametersEncode() throws {
        let params = ConversationItemCreateParameters(role: "user", content: "hello")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["type"] as? String, "message")
        XCTAssertEqual(object["role"] as? String, "user")
        XCTAssertEqual(object["content"] as? String, "hello")
    }

    func testConversationMethodsAreExposed() {
        let client = makeClient()

        let createConversation: (ConversationCreateParameters) async throws -> ConversationObject = client.conversations.create
        let listConversation: () async throws -> ConversationListResponse = client.conversations.list
        let retrieveConversation: (String) async throws -> ConversationObject = client.conversations.retrieve
        let deleteConversation: (String) async throws -> DeleteObject = client.conversations.delete

        let listItems: (String) async throws -> ConversationItemListResponse = client.conversations.items.list
        let createItem: (String, ConversationItemCreateParameters) async throws -> ConversationItemObject = client.conversations.items.create
        let retrieveItem: (String, String) async throws -> ConversationItemObject = client.conversations.items.retrieve
        let deleteItem: (String, String) async throws -> DeleteObject = client.conversations.items.delete

        XCTAssertNotNil(createConversation)
        XCTAssertNotNil(listConversation)
        XCTAssertNotNil(retrieveConversation)
        XCTAssertNotNil(deleteConversation)
        XCTAssertNotNil(listItems)
        XCTAssertNotNil(createItem)
        XCTAssertNotNil(retrieveItem)
        XCTAssertNotNil(deleteItem)
    }
}
