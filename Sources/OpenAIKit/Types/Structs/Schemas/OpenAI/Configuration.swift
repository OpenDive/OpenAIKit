//
//  Configuration.swift
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

/// The configuration object used for the OpenAIKit object to represent the organization of the user.
import Foundation

public struct Configuration: Sendable {
    /// The API key associated with the user.
    public let apiKey: String

    /// Optional organization header value.
    public let organizationId: String?

    /// Optional project header value.
    public let projectId: String?

    /// Optional webhook secret used by webhook verification helpers.
    public let webhookSecret: String?

    /// Base URL for all API requests.
    public let baseURL: URL

    /// Request behavior defaults used by the transport layer.
    public let requestOptions: OpenAIRequestOptions

    /// Backward-compatible initializer used by existing call sites.
    public init(organizationId: String, apiKey: String) {
        self.init(
            apiKey: apiKey,
            organizationId: organizationId,
            projectId: nil,
            webhookSecret: nil,
            baseURL: URL(string: "https://api.openai.com/v1")!,
            requestOptions: OpenAIRequestOptions()
        )
    }

    public init(
        apiKey: String,
        organizationId: String? = nil,
        projectId: String? = nil,
        webhookSecret: String? = nil,
        baseURL: URL = URL(string: "https://api.openai.com/v1")!,
        requestOptions: OpenAIRequestOptions = OpenAIRequestOptions()
    ) {
        self.apiKey = apiKey
        self.organizationId = organizationId
        self.projectId = projectId
        self.webhookSecret = webhookSecret
        self.baseURL = baseURL
        self.requestOptions = requestOptions
    }
}
