//
//  CompletionModels.swift
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

/// Models used for the Completion endpoint
public enum CompletionModels: String, CustomStringConvertible {
    /// Very capable, faster and lower cost than Davinci.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case textCurie001 = "text-curie-001"

    /// Capable of straightforward tasks, very fast, and lower cost.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case textBabbage001 = "text-babbage-001"

    /// Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case textAda001 = "text-ada-001"

    /// Most capable GPT-3 model. Can do any task the other models can do, often with higher quality.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case davinci

    /// Very capable, but faster and lower cost than Davinci.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case curie

    /// Capable of straightforward tasks, very fast, and lower cost.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case babbage

    /// Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.
    @available(*, deprecated, message: "On July 06, 2023, OpenAI announced the upcoming retirements of older GPT-3 and GPT-3.5 models served via the completions endpoint. OpenAI also announced the upcoming retirement of their first-generation text embedding models. They will be shut down on January 04, 2024.")
    case ada

    /// The maximum tokens the models can read
    public var maxTokens: [String : Int] {
        [
            "text-curie-001": 2049,
            "text-babbage-001": 2049,
            "text-ada-001": 2049,
            "davinci": 2049,
            "curie": 2049,
            "babbage": 2049,
            "ada": 2049
        ]
    }

    public var description: String {
        self.rawValue
    }
}
