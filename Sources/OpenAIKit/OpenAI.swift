//
//  OpenAI.swift
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

import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public class OpenAI {
    private var config: Configuration
    
    public init(_ config: Configuration) {
        self.config = config
    }
    
    private func getServerUrl(path: String) async throws -> URL {
        guard let result = URL(string: "https://api.openai.com/v1\(path)") else {
            throw OpenAIError.invalidUrl
        }
        
        return result
    }
}

extension OpenAI: OpenAIProtocol {
    public func generateImages(parameters param: ImageParameters) async throws -> ImageResponse {
        guard !param.prompt.isEmpty else { throw OpenAIError.invalidPrompt }
        
        let serverUrl = try await getServerUrl(path: "/images/generations")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }
    
    public func checkContentPolicy(
        parameters param: OpenAIKit.ContentPolicyParameters
    ) async throws -> ContentPolicyResponse {
        let serverUrl = try await getServerUrl(path: "/moderations")
        return try await URLSession.shared.decodeUrl(with: serverUrl, apiKey: config.apiKey, body: param.body)
    }
}
