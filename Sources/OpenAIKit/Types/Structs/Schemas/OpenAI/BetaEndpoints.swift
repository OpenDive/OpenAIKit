//
//  BetaEndpoints.swift
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

/// Provides any additional beta endpoints that are still actively under development.
public final class BetaEndpoints {
    /// The configuration object used to store the API Key and Organization ID.
    private var config: Configuration

    internal init(_ config: Configuration) {
        self.config = config
    }

    /// Return a `URL` with the OpenAI API endpoint as the `URL`
    /// - Parameter path: The `String` path.
    /// - Returns: An `URL` object.
    private func getServerUrl(path: String) throws -> URL {
        guard let result = URL(string: "https://api.openai.com/v1\(path)") else {
            throw OpenAIError.invalidUrl
        }

        return result
    }
}

extension BetaEndpoints: BetaEndpointsProtocol {
    public func createAssistants(parameters param: AssistantParameter) async throws -> Assistant {
        let serverUrl = try getServerUrl(path: "/assistants")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func retrieveAssistant(assistantId id: String) async throws -> Assistant {
        let serverUrl = try getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func modifyAssistant(assistantId id: String, parameters param: AssistantParameter) async throws -> Assistant {
        let serverUrl = try getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func deleteAssistant(assistantId id: String) async throws -> DeleteObject {
        let serverUrl = try getServerUrl(path: "/assistants/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .delete,
            bodyRequired: false
        )
    }

    public func listAssistants(parameters param: AssistantListParameter) async throws -> AssistantList {
        let serverUrl = try getServerUrl(path: "/assistants")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body,
            method: .get
        )
    }
}
