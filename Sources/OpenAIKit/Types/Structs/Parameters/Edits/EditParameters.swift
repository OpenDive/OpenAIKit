//
//  EditParameters.swift
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

/// Parameter struct for the Edit endpoint.
public struct EditParameters {
    /// ID of the model to use.
    ///
    /// You can use the [List models](https://beta.openai.com/docs/api-reference/models/list)
    /// API to see all of your available models, or see our [Model overview](https://beta.openai.com/docs/models/overview)
    /// for descriptions of them.
    public var model: String

    /// The input text to use as a starting point for the edit.
    public var input: String

    /// The instruction that tells the model how to edit the prompt.
    public var instruction: String

    /// How many edits to generate for the input and instruction.
    public var numberOfEdits: Int

    /// What [sampling temperature](https://towardsdatascience.com/how-to-sample-from-language-models-682bceb97277)
    /// to use.
    ///
    /// Higher values means the model will take more risks.
    /// Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
    ///
    /// We generally recommend altering this or `top_p` but not both.
    public var temperature: Double

    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `top_p` probability mass.
    ///
    /// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// We generally recommend altering this or `temperature` but not both.
    public var topP: Double

    public init(
        model: String,
        input: String = "\"",
        instruction: String,
        numberOfEdits: Int = 1,
        temperature: Double = 1.0,
        topP: Double = 1.0
    ) {
        self.model = model
        self.input = input
        self.instruction = instruction
        self.numberOfEdits = numberOfEdits
        self.temperature = temperature
        self.topP = topP
    }

    /// The body of the URL used for OpenAI API requests.
    public var body: [String: Any] {
        return [
            "model": self.model,
            "input": self.input,
            "instruction": self.instruction,
            "n": self.numberOfEdits,
            "temperature": self.temperature,
            "top_p": self.topP
        ]
    }
}
