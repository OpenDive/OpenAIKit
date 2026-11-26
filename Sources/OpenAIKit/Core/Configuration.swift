// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// Credentials and defaults for an `OpenAI` client.
public struct Configuration: Sendable {
    /// The default API base URL.
    public static let defaultBaseURL = URL(string: "https://api.openai.com/v1")!

    /// The API key sent as a bearer token. Required for every operation except the Administration API.
    public var apiKey: String?

    /// An admin API key, used only by `client.admin` operations.
    public var adminAPIKey: String?

    /// Sent as the `OpenAI-Organization` header when set.
    public var organizationId: String?

    /// Sent as the `OpenAI-Project` header when set.
    public var projectId: String?

    /// The secret `client.webhooks.verifySignature(...)` and `unwrap(...)` use when you do not pass one.
    public var webhookSecret: String?

    /// Base URL for all requests. Change it to use a proxy or a compatible server.
    public var baseURL: URL

    /// Timeout, retry and header defaults for every request.
    public var requestOptions: OpenAIRequestOptions

    public init(
        apiKey: String? = nil,
        adminAPIKey: String? = nil,
        organizationId: String? = nil,
        projectId: String? = nil,
        webhookSecret: String? = nil,
        baseURL: URL = Configuration.defaultBaseURL,
        requestOptions: OpenAIRequestOptions = OpenAIRequestOptions()
    ) {
        self.apiKey = apiKey
        self.adminAPIKey = adminAPIKey
        self.organizationId = organizationId
        self.projectId = projectId
        self.webhookSecret = webhookSecret
        self.baseURL = baseURL
        self.requestOptions = requestOptions
    }

    /// Reads `OPENAI_API_KEY`, `OPENAI_ADMIN_KEY`, `OPENAI_ORG_ID`, `OPENAI_PROJECT_ID`,
    /// `OPENAI_WEBHOOK_SECRET` and `OPENAI_BASE_URL`, the variables the official SDKs use.
    ///
    /// Use this on servers and in command-line tools. Do not ship an API key inside an app.
    public static func fromEnvironment(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> Configuration {
        func value(_ name: String) -> String? {
            guard let value = environment[name], !value.isEmpty else { return nil }
            return value
        }
        return Configuration(
            apiKey: value("OPENAI_API_KEY"),
            adminAPIKey: value("OPENAI_ADMIN_KEY"),
            organizationId: value("OPENAI_ORG_ID"),
            projectId: value("OPENAI_PROJECT_ID"),
            webhookSecret: value("OPENAI_WEBHOOK_SECRET"),
            baseURL: value("OPENAI_BASE_URL").flatMap(URL.init(string:)) ?? Configuration.defaultBaseURL
        )
    }
}

/// Timeout, retry and header settings. Set them on `Configuration` for every request, or pass them
/// as `options:` to a single call. Values you leave `nil` fall back to the configuration, then to the defaults.
public struct OpenAIRequestOptions: Sendable {
    /// Default timeout: 10 minutes, matching the official SDKs.
    public static let defaultTimeout: TimeInterval = 600
    /// Default retry count for connection errors, 408, 409, 429 and 5xx responses.
    public static let defaultMaxRetries = 2

    /// Seconds to wait for the request. `nil` means the configured value, then 600.
    public var timeoutInterval: TimeInterval?

    /// How many times to retry a failed request. `nil` means the configured value, then 2.
    public var maxRetries: Int?

    /// Headers merged into the request, replacing any header with the same name.
    public var additionalHeaders: [String: String]

    /// Query items appended to the request URL.
    public var additionalQuery: [String: String]

    public init(
        timeoutInterval: TimeInterval? = nil,
        maxRetries: Int? = nil,
        additionalHeaders: [String: String] = [:],
        additionalQuery: [String: String] = [:]
    ) {
        self.timeoutInterval = timeoutInterval
        self.maxRetries = maxRetries.map { max($0, 0) }
        self.additionalHeaders = additionalHeaders
        self.additionalQuery = additionalQuery
    }

    /// These options with `other` applied on top.
    func merging(_ other: OpenAIRequestOptions?) -> OpenAIRequestOptions {
        guard let other else { return self }
        return OpenAIRequestOptions(
            timeoutInterval: other.timeoutInterval ?? timeoutInterval,
            maxRetries: other.maxRetries ?? maxRetries,
            additionalHeaders: additionalHeaders.merging(other.additionalHeaders) { _, new in new },
            additionalQuery: additionalQuery.merging(other.additionalQuery) { _, new in new }
        )
    }

    var resolvedTimeout: TimeInterval { timeoutInterval ?? Self.defaultTimeout }
    var resolvedMaxRetries: Int { maxRetries ?? Self.defaultMaxRetries }
}
