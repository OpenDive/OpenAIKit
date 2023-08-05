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

public enum ChatModels: String, CustomStringConvertible {
    case chatGPTTurbo = "gpt-3.5-turbo"
    case chatGPTTurbo16k = "gpt-3.5-turbo-16k"
    case chatGPTTurbo0613 = "gpt-3.5-turbo-0613"
    case chatGPTTurbo16k0613 = "gpt-3.5-turbo-16k-0613"
    case textDavinci003 = "text-davinci-003"
    case textDavinci002 = "text-davinci-002"
    case gpt4 = "gpt-4"
    case gpt4_0613 = "gpt-4-0613"
    case gpt4_32k = "gpt-4-32k"
    case gpt4_32k0613 = "gpt-4-32k-0613"

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
