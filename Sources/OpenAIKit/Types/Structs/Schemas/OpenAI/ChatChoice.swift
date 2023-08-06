//
//  ChatChoice.swift
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

/// The output choice for the Chat Ednpoint.
public struct ChatChoice: Codable {
    enum CodingKeys: String, CodingKey {
        case message
        case delta
        case index
        case logprobs
        case finishReason = "finish_reason"
    }

    /// The choice output itself.
    public let message: ChatMessage?

    /// The streamed output if chosen to stream.
    public let delta: ChatDelta?

    /// The index of the choice within the data array.
    public let index: Int

    /// The logprobs used for the choice.
    public let logprobs: Int?

    /// The choice end reason.
    public let finishReason: String?
}

public struct ChatDelta: Codable {
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public let role: ChatRole?
    public let content: String?
}
