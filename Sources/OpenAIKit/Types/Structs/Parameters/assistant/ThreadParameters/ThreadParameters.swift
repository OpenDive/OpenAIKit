//
//  ThreadParameters.swift
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

public struct ThreadParameters {
    /// A list of [messages](https://platform.openai.com/docs/api-reference/messages) to start the thread with.
    public var messages: [ThreadMessageParameters]?

    /// Set of 16 key-value pairs that can be attached to an object.
    /// This can be useful for storing additional information about the object in a structured format.
    /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
    public var metadata: [String: String]?

    public init(messages: [ThreadMessageParameters]? = nil, metadata: [String: String]? = nil) {
        self.messages = messages
        self.metadata = metadata
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [:]

        if let messages = self.messages {
            result["messages"] = messages
        }

        if let metadata = self.metadata {
            result["metadata"] = metadata
        }

        return result
    }
}
