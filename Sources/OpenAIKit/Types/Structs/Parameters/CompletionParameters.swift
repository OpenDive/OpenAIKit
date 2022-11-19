//
//  CompletionParameters.swift
//  OpenAIKit
//
//  Copyright (c) 2022 MarcoDotIO
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

public struct CompletionParameters {
    var model: String
    var prompt: [String]
    var suffix: String?
    var maxTokens: Int
    var temperature: Double
    var topP: Double
    var numberOfCompletions: Int
    var stream: Bool
    var logprobs: Int?
    var echo: Bool
    var stop: [String]?
    var presencePenalty: Double
    var frequencyPenalty: Double
    var bestOf: Int
    var logitBias: [String: Int]?
    var user: String?
    
    public init(
        model: String,
        prompt: [String] = ["<|endoftext|>"],
        suffix: String? = nil,
        maxTokens: Int = 16,
        temperature: Double = 1.0,
        topP: Double = 1.0,
        @Clamped(range: 1...10) numberOfCompletions: Int = 1,
        stream: Bool = false,
        logprobs: Int? = nil,
        maxLogprobs: Int = 5,
        echo: Bool = false,
        stop: [String]? = nil,
        @Clamped(range: -2.0...2.0) presencePenalty: Double = 0.0,
        @Clamped(range: -2.0...2.0) frequencyPenalty: Double = 0.0,
        bestOf: Int = 1,
        logitBias: [String : Int]? = nil,
        user: String? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.suffix = suffix
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.numberOfCompletions = numberOfCompletions
        self.stream = stream
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
    
    public var body: [String: Any] {
        var result: [String: Any] = [
            "model": self.model,
            "prompt": self.prompt,
            "max_tokens": self.maxTokens,
            "temperature": self.temperature,
            "top_p": self.topP,
            "n": self.numberOfCompletions,
            "stream": self.stream,
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
