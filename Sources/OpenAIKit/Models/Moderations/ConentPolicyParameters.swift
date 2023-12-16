//
//  ContentPolicyParameters.swift
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

/// The parameter struct used for the Moderations endpoint
public struct ContentPolicyParameters {
    /// The input text to classify.
    public var input: String

    /// Two content moderations models are available: `text-moderation-stable` and `text-moderation-latest`.
    ///
    /// The default is `text-moderation-latest` which will be automatically upgraded over time.
    /// This ensures you are always using our most accurate model. If you use `text-moderation-stable`,
    /// we will provide advanced notice before updating the model. Accuracy of `text-moderation-stable`
    /// may be slightly lower than for `text-moderation-latest`.
    public var model: ContentPolicyModels

    public init(
        input: String,
        model: ContentPolicyModels = .latest
    ) {
        self.input = input
        self.model = model
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        return ["input": self.input, "model": self.model.rawValue]
    }
}
