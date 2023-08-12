//
//  CompletionParameters.swift
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

/// Parameter struct used for creating GPT3 completions.
public struct CompletionParameters {
    /// ID of the model to use.
    ///
    /// You can use the [List models](https://beta.openai.com/docs/api-reference/models/list)
    /// API to see all of your available models, or see our [Model overview](https://beta.openai.com/docs/models/overview)
    /// for descriptions of them.
    public var model: CompletionModels

    /// The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
    ///
    /// Note that `<|endoftext|>` is the document separator that the model sees during training, so if a prompt is not specified the
    /// model will generate as if from the beginning of a new document.
    public var prompt: [String]

    /// The suffix that comes after a completion of inserted text.
    public var suffix: String?

    /// The maximum number of [tokens](https://beta.openai.com/tokenizer) to generate in the completion.
    ///
    /// The token count of your prompt plus `max_tokens` cannot exceed the model's context length. Most models have
    /// a context length of 2048 tokens (except for the newest models, which support 4096).
    public var maxTokens: Int

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

    /// How many completions to generate for each prompt.
    ///
    /// **Note:** Because this parameter generates many completions, it can quickly consume your token quota.
    /// Use carefully and ensure that you have reasonable settings for `max_tokens` and `stop`.
    public var numberOfCompletions: Int

    /// Include the log probabilities on the `logprobs` most likely tokens, as well the chosen tokens.
    ///
    /// For example, if `logprobs` is 5, the API will return a list of the 5 most likely tokens.
    /// The API will always return the `logprob` of the sampled token,
    /// so there may be up to `logprobs+1` elements in the response.
    ///
    /// The maximum value for `logprobs is 5`. If you need more than this,
    /// please contact us through our [Help center](https://help.openai.com/) and describe your use case.
    public var logprobs: Int?

    /// Echo back the prompt in addition to the completion.
    public var echo: Bool

    /// Up to 4 sequences where the API will stop generating further tokens.
    /// The returned text will not contain the stop sequence.
    public var stop: [String]?

    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far,
    /// increasing the model's likelihood to talk about new topics.
    ///
    /// [See more information about frequency and presence penalties.](https://beta.openai.com/docs/api-reference/parameter-details)
    public var presencePenalty: Double

    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far,
    /// decreasing the model's likelihood to repeat the same line verbatim.
    ///
    /// [See more information about frequency and presence penalties.](https://beta.openai.com/docs/api-reference/parameter-details)
    public var frequencyPenalty: Double

    /// Generates `best_of` completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
    /// When used with `n`, `best_of` controls the number of candidate completions and `n` specifies how many to return – `best_of` must be greater than `n`.
    ///
    /// **Note:** Because this parameter generates many completions, it can quickly consume your token quota. Use carefully and ensure that you have reasonable settings for
    /// `max_tokens` and `stop`.
    public var bestOf: Int

    /// Modify the likelihood of specified tokens appearing in the completion.
    ///
    /// Accepts a json object that maps tokens (specified by their token ID in the GPT tokenizer) to an associated bias value from -100 to 100.
    /// You can use this [tokenizer tool](https://beta.openai.com/tokenizer?view=bpe) (which works for both GPT-2 and GPT-3) to convert text to token IDs.
    /// Mathematically, the bias is added to the logits generated by the model prior to sampling.
    /// The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection;
    /// values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    ///
    /// As an example, you can pass `{"50256": -100}` to prevent the `<|endoftext|>` token from being generated.
    public var logitBias: [String: Int]?

    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// [Learn more.](https://beta.openai.com/docs/guides/safety-best-practices/end-user-ids)
    public var user: String?

    public init(
        model: CompletionModels,
        prompt: [String] = ["<|endoftext|>"],
        suffix: String? = nil,
        maxTokens: Int = 16,
        temperature: Double = 1.0,
        topP: Double = 1.0,
        @Clamped(range: 1...10) numberOfCompletions: Int = 1,
        logprobs: Int? = nil,
        maxLogprobs: Int = 5,
        echo: Bool = false,
        stop: [String]? = nil,
        @Clamped(range: -2.0...2.0) presencePenalty: Double = 0.0,
        @Clamped(range: -2.0...2.0) frequencyPenalty: Double = 0.0,
        bestOf: Int = 1,
        logitBias: [String: Int]? = nil,
        user: String? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.suffix = suffix
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.numberOfCompletions = numberOfCompletions
        self.echo = echo
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.bestOf = bestOf
        self.logitBias = logitBias
        self.user = user

        if let logprobs = logprobs {
            if logprobs > maxLogprobs {
                self.logprobs = maxLogprobs
            } else if logprobs < 1 {
                self.logprobs = 1
            } else {
                self.logprobs = logprobs
            }
        } else {
            self.logprobs = nil
        }
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "model": self.model.description,
            "prompt": self.prompt,
            "max_tokens": self.maxTokens,
            "temperature": self.temperature,
            "top_p": self.topP,
            "n": self.numberOfCompletions,
            "echo": self.echo,
            "presence_penalty": self.presencePenalty,
            "frequency_penalty": self.frequencyPenalty,
            "best_of": self.bestOf
        ]

        if let suffix = self.suffix {
            result["suffix"] = suffix
        }

        if let logprobs = self.logprobs {
            result["logprobs"] = logprobs
        }

        if let stop = self.stop {
            result["stop"] = stop
        }

        if let logitBias = self.logitBias {
            result["logit_bias"] = logitBias
        }

        if let user = self.user {
            result["user"] = user
        }

        return result
    }
}
