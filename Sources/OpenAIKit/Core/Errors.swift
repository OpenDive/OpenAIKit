// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// Errors OpenAIKit throws before or after talking to the API.
///
/// HTTP error responses throw ``OpenAIAPIError`` instead.
public enum OpenAIError: Error, Sendable, LocalizedError {
    /// `Configuration.apiKey` is not set and requests go straight to OpenAI.
    case missingAPIKey
    /// The operation is part of the Administration API, `Configuration.adminAPIKey` is not set, and requests go straight to OpenAI.
    case missingAdminAPIKey
    /// The base URL and path did not form a valid URL.
    case invalidURL(String)
    /// The request could not reach the server: no network, DNS failure, dropped connection.
    case connection(any Error)
    /// The request took longer than its timeout.
    case timeout
    /// The response was successful but its body did not match the expected type.
    case decoding(type: String, underlying: any Error, body: Data)
    /// The request body could not be encoded.
    case encoding(any Error)
    /// A server-sent event stream was malformed.
    case invalidStream(String)

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key. Set Configuration.apiKey or OPENAI_API_KEY."
        case .missingAdminAPIKey:
            return "This is an Administration API operation. Set Configuration.adminAPIKey or OPENAI_ADMIN_KEY."
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .connection(let error):
            return "Connection error: \(error.localizedDescription)"
        case .timeout:
            return "The request timed out."
        case .decoding(let type, let underlying, _):
            return "Could not decode \(type): \(underlying)"
        case .encoding(let error):
            return "Could not encode the request: \(error)"
        case .invalidStream(let reason):
            return "Invalid event stream: \(reason)"
        }
    }
}

/// An error response from the OpenAI API.
public struct OpenAIAPIError: Error, Sendable, LocalizedError {
    public enum Kind: Sendable, Equatable {
        case badRequest
        case authentication
        case permissionDenied
        case notFound
        case conflict
        case unprocessableEntity
        case rateLimit
        case internalServer
        /// An error event inside a stream.
        case streamError
        case other
    }

    /// HTTP status code, or 0 for an error delivered inside a stream.
    public let statusCode: Int
    /// The `error.message` field, if the body had one.
    public let message: String
    /// The `error.type` field.
    public let type: String?
    /// The `error.code` field.
    public let code: String?
    /// The `error.param` field.
    public let param: String?
    /// The `x-request-id` header. Include it when you contact OpenAI support.
    public let requestID: String?
    /// Response headers.
    public let headers: [String: String]
    /// The raw response body.
    public let body: Data

    public var kind: Kind {
        switch statusCode {
        case 0: return .streamError
        case 400: return .badRequest
        case 401: return .authentication
        case 403: return .permissionDenied
        case 404: return .notFound
        case 409: return .conflict
        case 422: return .unprocessableEntity
        case 429: return .rateLimit
        case 500...: return .internalServer
        default: return .other
        }
    }

    public var errorDescription: String? {
        "\(statusCode == 0 ? "Stream error" : "HTTP \(statusCode)"): \(message)"
    }

    public init(statusCode: Int, body: Data, headers: [String: String]) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
        self.requestID = headers.first { $0.key.lowercased() == "x-request-id" }?.value
        let json = try? JSONDecoder().decode(JSONValue.self, from: body)
        let error = json?["error"] ?? json
        func text(_ value: JSONValue?) -> String? {
            switch value {
            case .string(let string): return string
            case .integer(let int): return String(int)
            case .number(let number): return String(number)
            default: return nil
            }
        }
        self.message = text(error?["message"]) ?? (String(data: body, encoding: .utf8).flatMap { $0.isEmpty ? nil : $0 } ?? "Unknown error")
        self.type = text(error?["type"])
        self.code = text(error?["code"])
        self.param = text(error?["param"])
    }
}
