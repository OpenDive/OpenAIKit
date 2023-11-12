//
//  AssistantMessage.swift
//  OpenAIKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public struct AssistantMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case threadId = "thread_id"
        case role
        case content
        case assistantId = "assistant_id"
        case runId = "run_id"
        case fileIds = "file_ids"
        case metadata
    }

    /// The identifier, which can be referenced in API endpoints.
    public let id: String

    /// The object type, which is always `thread.message`.
    public let object: OpenAIObject

    /// The Unix timestamp (in seconds) for when the message was created.
    public let createdAt: Int

    /// The [thread](https://platform.openai.com/docs/api-reference/threads) ID that this message belongs to.
    public let threadId: String

    /// The entity that produced the message. One of `user` or `assistant`.
    public let role: ChatRole

    /// The content of the message in array of text and/or images.
    public let content: MessageContent

    /// If applicable, the ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) that authored this message.
    public let assistantId: String?

    /// If applicable, the ID of the [run](https://platform.openai.com/docs/api-reference/runs) associated with the authoring of this message.
    public let runId: String?

    /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs that the assistant should use.
    ///
    /// Useful for tools like retrieval and code_interpreter that can access files. A maximum of 10 files can be attached to a message.
    public let fileIds: [String]

    /// Set of 16 key-value pairs that can be attached to an object.
    ///
    /// This can be useful for storing additional information about the object in a structured format.
    /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    public let metadata: [String: String]
}
