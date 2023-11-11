//
//  Assistant.swift
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

public struct Assistant: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case name
        case description
        case model
        case instructions
        case tools
        case metadata
        case createdAt = "created_at"
        case fileIds = "file_ids"
    }

    /// The identifier, which can be referenced in API endpoints.
    public let id: String

    /// The object type, which is always `assistant`.
    public let object: OpenAIObject

    /// The Unix timestamp (in seconds) for when the assistant was created.
    public let createdAt: Int

    /// The name of the assistant. The maximum length is 256 characters.
    public let name: String?

    /// The description of the assistant. The maximum length is 512 characters.
    public let description: String?

    /// ID of the model to use.
    ///
    /// You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models,
    /// or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
    public let model: String

    /// The system instructions that the assistant uses. The maximum length is 32768 characters.
    public let instructions: String?

    /// A list of tool enabled on the assistant.
    ///
    /// There can be a maximum of 128 tools per assistant. Tools can be of types `.codeInterpreter`, `.retrieval`, or `.function`.
    public let tools: [AssistantTool]

    /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant.
    ///
    /// There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
    public let fileIds: [String]

    /// Set of 16 key-value pairs that can be attached to an object.
    ///
    /// This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    public let metadata: [String: String]
}
