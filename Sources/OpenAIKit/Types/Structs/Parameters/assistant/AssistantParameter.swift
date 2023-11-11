//
//  AssistantParameter.swift
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

public struct AssistantParameter {
    /// ID of the model to use.
    ///
    /// You can use the [List models](https://platform.openai.com/docs/api-reference/models/list) API to see all of your available models,
    /// or see our [Model overview](https://platform.openai.com/docs/models/overview) for descriptions of them.
    public var model: ChatModels

    /// The name of the assistant. The maximum length is 256 characters.
    public var name: String?

    /// The description of the assistant. The maximum length is 512 characters.
    public var description: String?

    /// The system instructions that the assistant uses. The maximum length is 32768 characters.
    public var instructions: String?

    /// A list of tool enabled on the assistant.
    ///
    /// There can be a maximum of 128 tools per assistant. Tools can be of types `.codeInterpreter`, `.retrieval`, or `.function`.
    public var tools: [AssistantTool]

    /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs attached to this assistant.
    ///
    /// There can be a maximum of 20 files attached to the assistant. Files are ordered by their creation date in ascending order.
    public var fileIds: [String]

    /// Set of 16 key-value pairs that can be attached to an object.
    ///
    /// This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    public var metadata: [String: String]

    public init(
        model: ChatModels,
        name: String? = nil,
        description: String? = nil,
        instructuons: String? = nil,
        tools: [AssistantTool] = [],
        fileIds: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.model = model
        self.name = name
        self.description = description
        self.tools = tools
        self.fileIds = fileIds
        self.metadata = metadata
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "model": self.model,
            "tools": self.tools.map { $0.body },
            "file_ids": self.fileIds,
            "metadata": self.metadata
        ]

        if let name = self.name {
            result["name"] = name
        }

        if let description = self.description {
            result["description"] = description
        }

        if let instructions = self.instructions {
            result["instructions"] = instructions
        }

        return result
    }
}
