//
//  EmbeddingsParameters.swift
//  OpenAIKit
//
//  Copyright (c) 2023 MarcoDotIO
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

/// Parameter used for the Embeddings endpoint.
public struct EmbeddingsParameters {
    /// ID of the model to use.
    ///
    /// You can use the [List models](https://beta.openai.com/docs/api-reference/models/list)
    /// API to see all of your available models, or see our [Model overview](https://beta.openai.com/docs/models/overview)
    /// for descriptions of them.
    public var model: String

    /// Input text to get embeddings for, encoded as a string or array of tokens.
    ///
    /// To get embeddings for multiple inputs in a single request, pass an array of strings or array of token arrays.
    /// Each input must not exceed 2048 tokens in length.
    ///
    /// Unless you are embedding code, we suggest replacing newlines (`\n`) in your input with a single space,
    /// as we have observed inferior results when newlines are present.
    public var input: String

    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// [Learn more.](https://beta.openai.com/docs/guides/safety-best-practices/end-user-ids)
    public var user: String?

    public init(
        model: String = "text-embedding-ada-002",
        input: String,
        user: String? = nil
    ) {
        self.model = model
        self.input = input
        self.user = user
    }

    /// The body of the URL used for OpenAI API requests.
    public var body: [String: Any] {
        var result: [String: Any] = ["model": self.model, "input": self.input]

        if let user = user {
            result["user"] = user
        }

        return result
    }
}
