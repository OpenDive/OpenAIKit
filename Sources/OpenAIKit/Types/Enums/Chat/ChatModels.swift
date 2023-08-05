//
//  ChatModels.swift
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

import Foundation

/// Models used for the Chat Endpoint.
public enum ChatModels: String, CustomStringConvertible {
    // MARK: ChatGPT Models

    /// Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of text-davinci-003. Will be updated with our latest model iteration 2 weeks after it is released.
    case chatGPTTurbo = "gpt-3.5-turbo"

    /// Same capabilities as the standard gpt-3.5-turbo model but with 4 times the context.
    case chatGPTTurbo16k = "gpt-3.5-turbo-16k"

    /// Snapshot of gpt-3.5-turbo from June 13th 2023 with function calling data. Unlike gpt-3.5-turbo, this model will not receive updates, and will be deprecated 3 months after a new version is released.
    case chatGPTTurbo0613 = "gpt-3.5-turbo-0613"

    /// Snapshot of gpt-3.5-turbo-16k from June 13th 2023. Unlike gpt-3.5-turbo-16k, this model will not receive updates, and will be deprecated 3 months after a new version is released.
    case chatGPTTurbo16k0613 = "gpt-3.5-turbo-16k-0613"

    /// Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports some additional features such as [inserting text](https://platform.openai.com/docs/guides/gpt/inserting-text).
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of our first-generation text embedding models. They will be shut down on January 04, 2024.")
    case textDavinci003 = "text-davinci-003"

    /// Similar capabilities to text-davinci-003 but trained with supervised fine-tuning instead of reinforcement learning
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of our first-generation text embedding models. They will be shut down on January 04, 2024.")
    case textDavinci002 = "text-davinci-002"

    // MARK: GPT-4 Models

    /// More capable than any GPT-3.5 model, able to do more complex tasks, and optimized for chat. Will be updated with our latest model iteration 2 weeks after it is released.
    case gpt4 = "gpt-4"

    /// Snapshot of gpt-4 from June 13th 2023 with function calling data. Unlike gpt-4, this model will not receive updates, and will be deprecated 3 months after a new version is released.
    case gpt4_0613 = "gpt-4-0613"

    /// Same capabilities as the base gpt-4 mode but with 4x the context length. Will be updated with our latest model iteration.
    case gpt4_32k = "gpt-4-32k"

    /// Snapshot of gpt-4-32 from June 13th 2023. Unlike gpt-4-32k, this model will not receive updates, and will be deprecated 3 months after a new version is released.
    case gpt4_32k0613 = "gpt-4-32k-0613"

    /// The maximum tokens the models can read
    public var maxTokens: [String : Int] {
        [
            "gpt-3.5-turbo": 4096,
            "gpt-3.5-turbo-16k": 16384,
            "gpt-3.5-turbo-0613": 4096,
            "gpt-3.5-turbo-16k-0613": 16384,
            "text-davinci-003": 4097,
            "text-davinci-002": 4097,
            "gpt-4": 8192,
            "gpt-4-0613": 8192,
            "gpt-4-32k": 32768,
            "gpt-4-32k-0613": 32768
        ]
    }

    public var description: String {
        self.rawValue
    }
}
