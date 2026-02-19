//
//  ChatParameters.swift
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

import Foundation

public struct ChatParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case numberOfCompletions = "n"
        case stream
        case stop
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case user
        case functionCall = "function_call"
        case functions
        case tools
        case toolChoice = "tool_choice"
        case responseFormat = "response_format"
        case seed
        case maxCompletionTokens = "max_completion_tokens"
        case maxTokens = "max_tokens"
        case parallelToolCalls = "parallel_tool_calls"
        case logprobs
        case topLogprobs = "top_logprobs"
    }
    /// ID of the model to use.
    public var model: ChatModels

    /// ID of the custom model created from fine-tuning.
    public var customModel: String?

    /// The messages to generate chat completions for, in the
    /// [chat format](https://platform.openai.com/docs/guides/chat/introduction).
    public var messages: [ChatMessage]

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

    /// Whether to stream back partial progress. If set, tokens will be sent as data-only
    /// [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#Event_stream_format)
    /// as they become available, with the stream terminated by a data: [DONE] message.
    public var stream: Bool

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

    /// Controls how the model calls functions. "none" means the model will not call a function and instead generates a message.
    /// "auto" means the model can pick between generating a message or calling a function. Specifying a particular function via
    /// {"name": "my_function"} forces the model to call that function. "none" is the default when no functions are present. "auto" is
    /// the default if functions are present.
    public var functionCall: String?

    /// A list of functions the model may generate JSON inputs for.
    public var functions: [Function]?

    /// A list of modern tools the model may call.
    public var tools: [ChatTool]?

    /// Controls which tool should be used by the model (`none`, `auto`, `required`).
    public var toolChoice: String?

    /// Structured output response format configuration.
    public var responseFormat: ChatResponseFormat?

    /// Optional deterministic seed.
    public var seed: Int?

    /// Upper bound for completion tokens.
    public var maxCompletionTokens: Int?

    /// Legacy max tokens field.
    public var maxTokens: Int?

    /// Controls whether the model can call tools in parallel.
    public var parallelToolCalls: Bool?

    /// Whether to include token log probabilities.
    public var logprobs: Bool?

    /// Number of top log probabilities to return.
    public var topLogprobs: Int?

    public init(
        model: ChatModels,
        customModel: String? = nil,
        messages: [ChatMessage],
        temperature: Double = 1.0,
        topP: Double = 1.0,
        numberOfCompletions: Int = 1,
        stream: Bool = false,
        stop: [String]? = nil,
        presencePenalty: Double = 0.0,
        frequencyPenalty: Double = 0.0,
        logitBias: [String : Int]? = nil,
        user: String? = nil,
        functionCall: String? = nil,
        functions: [Function]? = nil,
        tools: [ChatTool]? = nil,
        toolChoice: String? = nil,
        responseFormat: ChatResponseFormat? = nil,
        seed: Int? = nil,
        maxCompletionTokens: Int? = nil,
        maxTokens: Int? = nil,
        parallelToolCalls: Bool? = nil,
        logprobs: Bool? = nil,
        topLogprobs: Int? = nil
    ) {
        self.model = model
        self.customModel = customModel
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.numberOfCompletions = numberOfCompletions
        self.stream = stream
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.user = user
        self.functionCall = functionCall
        self.functions = functions
        self.tools = tools
        self.toolChoice = toolChoice
        self.responseFormat = responseFormat
        self.seed = seed
        self.maxCompletionTokens = maxCompletionTokens
        self.maxTokens = maxTokens
        self.parallelToolCalls = parallelToolCalls
        self.logprobs = logprobs
        self.topLogprobs = topLogprobs
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let selectedModel = self.customModel ?? self.model.rawValue

        try container.encode(selectedModel, forKey: .model)
        try container.encode(self.messages, forKey: .messages)
        try container.encode(self.temperature, forKey: .temperature)
        try container.encode(self.topP, forKey: .topP)
        try container.encode(self.numberOfCompletions, forKey: .numberOfCompletions)
        try container.encode(self.stream, forKey: .stream)
        try container.encode(self.presencePenalty, forKey: .presencePenalty)
        try container.encode(self.frequencyPenalty, forKey: .frequencyPenalty)

        try container.encodeIfPresent(self.stop, forKey: .stop)
        try container.encodeIfPresent(self.logitBias, forKey: .logitBias)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encodeIfPresent(self.functionCall, forKey: .functionCall)
        try container.encodeIfPresent(self.functions, forKey: .functions)
        try container.encodeIfPresent(self.tools, forKey: .tools)
        try container.encodeIfPresent(self.toolChoice, forKey: .toolChoice)
        try container.encodeIfPresent(self.responseFormat, forKey: .responseFormat)
        try container.encodeIfPresent(self.seed, forKey: .seed)
        try container.encodeIfPresent(self.maxCompletionTokens, forKey: .maxCompletionTokens)
        try container.encodeIfPresent(self.maxTokens, forKey: .maxTokens)
        try container.encodeIfPresent(self.parallelToolCalls, forKey: .parallelToolCalls)
        try container.encodeIfPresent(self.logprobs, forKey: .logprobs)
        try container.encodeIfPresent(self.topLogprobs, forKey: .topLogprobs)
    }
}
