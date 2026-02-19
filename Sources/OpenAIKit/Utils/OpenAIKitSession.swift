//
//  URLSessionExtension.swift
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

#if os(Linux) || SERVER
import FoundationNetworking
#endif

// Extensions used to help better streamline the main OpenAIKit class.
// Most are private to help with having better Access Control.
final class OpenAIKitSession: @unchecked Sendable {
    /// Shared Singleton object for use within the OpenAIKit API Module
    internal static let shared = OpenAIKitSession()

    /// Conforming to the Singleton Design Pattern
    private init() {  }

    /// Uses URLRequest to set up a HTTPMethod, and implement default values for the method cases.
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    internal func headers(for configuration: Configuration) -> [String: String] {
        var result: [String: String] = [
            "Authorization": "Bearer \(configuration.apiKey)"
        ]

        if let organizationId = configuration.organizationId, !organizationId.isEmpty {
            result["OpenAI-Organization"] = organizationId
        }

        if let projectId = configuration.projectId, !projectId.isEmpty {
            result["OpenAI-Project"] = projectId
        }

        configuration.requestOptions.additionalHeaders.forEach { key, value in
            result[key] = value
        }

        return result
    }

    internal static func statusError(for statusCode: Int, data: Data) -> OpenAIAPIError {
        let payload = try? OpenAIKitSession.decodeData(OpenAIErrorResponse.self, with: data)

        switch statusCode {
        case 400:
            return .badRequest(payload)
        case 401:
            return .authentication(payload)
        case 403:
            return .permissionDenied(payload)
        case 404:
            return .notFound(payload)
        case 409:
            return .conflict(payload)
        case 422:
            return .unprocessableEntity(payload)
        case 429:
            return .rateLimit(payload)
        case 500...599:
            return .internalServer(statusCode: statusCode, payload: payload)
        default:
            return .unexpectedStatusCode(statusCode: statusCode, payload: payload)
        }
    }

    internal static func validateStatus(_ response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIKitSession.statusError(for: httpResponse.statusCode, data: data)
        }
    }

    private func resolveRequestConfiguration(
        apiKey: String?,
        configuration: Configuration?
    ) throws -> (headers: [String: String], options: OpenAIRequestOptions) {
        if let configuration = configuration {
            return (self.headers(for: configuration), configuration.requestOptions)
        }

        guard let apiKey = apiKey else {
            throw OpenAIError.noApiKey
        }

        return (
            ["Authorization": "Bearer \(apiKey)"],
            OpenAIRequestOptions()
        )
    }

    /// Decode a data object using `JSONDecoder.decode()`.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - data: `Data` input object.
    ///   - keyDecodingStrategy: Default is `.useDefaultKeys`.
    ///   - dataDecodingStrategy: Default is `.deferredToData`.
    ///   - dateDecodingStrategy: Default is `.deferredToDate`.
    /// - Returns: Decoded data of `T` type, or throws an `OpenAIErrorRaesponse` object.
    internal static func decodeData<T: Decodable>(
        _ type: T.Type = T.self,
        with data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) throws -> T {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        guard let decoded = try? decoder.decode(type, from: data) else {
            throw try decoder.decode(OpenAIErrorResponse.self, from: data)
        }
        return decoded
    }

    /// Takes a `URL` input, along with header information, and converts it into a `URLRequest`;
    /// and fetches the data using an `Async` `Await` wrapper for the older `dataTask` handler.
    /// - Parameters:
    ///   - url: `URL` to convert to a `URLRequest`.
    ///   - method: Input can be either a `.get` or a `.post` method, with the default being `.post`.
    ///   - headers: Header data for the request that uses a `[string:string]` dictionary,
    ///   and the default is set to an empty dictionary.
    ///   - body: Body data that defaults to `nil`.
    /// - Returns: The data that was fetched typed as a `Data` object.
    internal func asyncData(
        with url: URL,
        method: HTTPMethod = .post,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval? = nil,
        maxRetries: Int = 0
    ) async throws -> (Data, URLResponse?) {
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }

        headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        return try await self.asyncData(with: request, maxRetries: maxRetries)
    }

    /// An Async Await wrapper for the older `dataTask` handler.
    /// - Parameter request: `URLRequest` to be fetched from.
    /// - Returns: A Data object fetched from the` URLRequest`.
    private func asyncData(
        with request: URLRequest,
        maxRetries: Int = 0
    ) async throws -> (Data, URLResponse?) {
        var attempt = 0
        while true {
            do {
                return try await self.performDataTask(with: request)
            } catch {
                if attempt >= maxRetries {
                    throw error
                }
                attempt += 1
            }
        }
    }

    private func performDataTask(with request: URLRequest) async throws -> (Data, URLResponse?) {
        try await withCheckedThrowingContinuation { (con: CheckedContinuation<(Data, URLResponse?), Error>) in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: (data, response))
                } else {
                    con.resume(returning: (Data(), response))
                }
            }

            task.resume()
        }
    }
    
    /// Used for parsing `.jsonl` files when retrieving fine-tuning files from OpenAI's server.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    /// - Returns: The decoded object of array type `T`.
    public func retrieveJsonLine<T: Decodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil
    ) async throws -> [T] {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )

        let jsonDecoder = JSONDecoder()

        let (genData, response) = try await self.asyncData(
            with: url,
            method: .get,
            headers: requestConfiguration.headers,
            timeoutInterval: requestConfiguration.options.timeoutInterval,
            maxRetries: requestConfiguration.options.maxRetries
        )
        try OpenAIKitSession.validateStatus(response, data: genData)

        let genString = String(decoding: genData, as: UTF8.self)

        return try genString.components(separatedBy: .newlines)
            .filter { $0 != "" }
            .compactMap { gen -> T? in
                guard let data = gen.data(using: .utf8) else {
                    throw OpenAIError.invalidData
                }
                return try? jsonDecoder.decode(T.self, from: data)
            }
    }

    /// Stream Data from a server using Server Side Events.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    ///   - body: The POST body used to add parameters, defaults to `nil`.
    ///   - method: The method used for the function, defaults to `.post`.
    /// - Returns: An `AsyncThrowingStream` object with either type `T` object or type `Error` object.
    public func streamData<T: Decodable & Sendable, Body: Encodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: Body,
        method: HTTPMethod = .post
    ) throws -> AsyncThrowingStream<T, Error> {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )
        let jsonData = try JSONEncoder().encode(body)
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = jsonData
        request.timeoutInterval = requestConfiguration.options.timeoutInterval
        requestConfiguration.headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        return OpenAISource(url: request).streamData()
    }

    /// Stream data using an untyped dictionary payload.
    public func streamData<T: Decodable & Sendable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: [String: Any],
        method: HTTPMethod = .post
    ) throws -> AsyncThrowingStream<T, Error> {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = jsonData
        request.timeoutInterval = requestConfiguration.options.timeoutInterval
        requestConfiguration.headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        return OpenAISource(url: request).streamData()
    }

    /// Decode a `URL` to the type `Data` using `asyncData()`
    /// - Parameters:
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    ///   - body: The POST body used to add parameters, defaults to `nil`.
    ///   - method: The method used for the function, defaults to `.post`.
    /// - Returns: The decoded object of type `Data`.
    public func decodeUrlTranscriptions(
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: [String: Any]
    ) async throws -> Data {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )
        let formRequest = FormDataHelper(formUrl: url)

        body.forEach { (key, value) in
            if let dataValue = value as? FormData {
                formRequest.addDataField(named: key, formData: dataValue)
            } else {
                formRequest.addTextField(named: key, value: "\(value)")
            }
        }

        var request = formRequest.asURLRequest(headers: requestConfiguration.headers)
        request.timeoutInterval = requestConfiguration.options.timeoutInterval

        let (data, response) = try await self.asyncData(
            with: request,
            maxRetries: requestConfiguration.options.maxRetries
        )
        try OpenAIKitSession.validateStatus(response, data: data)
        return data
    }

    /// Decode a URL to raw data using an encodable JSON body.
    public func decodeRawUrl<Body: Encodable>(
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: Body,
        method: HTTPMethod = .post,
        acceptHeader: String? = nil
    ) async throws -> Data {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )
        let jsonData = try JSONEncoder().encode(body)

        var headers = requestConfiguration.headers
        if let acceptHeader = acceptHeader {
            headers["Accept"] = acceptHeader
        }

        let (data, response) = try await self.asyncData(
            with: url,
            method: method,
            headers: headers,
            body: jsonData,
            timeoutInterval: requestConfiguration.options.timeoutInterval,
            maxRetries: requestConfiguration.options.maxRetries
        )
        try OpenAIKitSession.validateStatus(response, data: data)
        return data
    }

    /// Decode a `URL` to the type `T` using either `asyncData()` for the Production Server;
    /// or using `decode()` for the Mock Server.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    ///   - body: The POST body used to add parameters, defaults to `nil`.
    ///   - method: The method used for the function, defaults to `.post`.
    ///   - bodyRequired: Is the body required or not, used for `.get` and `.delete`, defaults to `false`.
    ///   - formSubmission: Is the body actually a form submission? Used for image submissionss, defaults to `false`.
    /// - Returns: The decoded object of type `T`.
    public func decodeUrl<T: Decodable, Body: Encodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: Body,
        method: HTTPMethod = .post
    ) async throws -> T {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )
        let jsonData = try JSONEncoder().encode(body)
        let (data, response) = try await self.asyncData(
            with: url,
            method: method,
            headers: requestConfiguration.headers,
            body: jsonData,
            timeoutInterval: requestConfiguration.options.timeoutInterval,
            maxRetries: requestConfiguration.options.maxRetries
        )
        try OpenAIKitSession.validateStatus(response, data: data)

        return try OpenAIKitSession.decodeData(with: data)
    }

    /// Decode a `URL` using an untyped dictionary payload.
    public func decodeUrl<T: Decodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        configuration: Configuration? = nil,
        body: [String: Any]? = nil,
        method: HTTPMethod = .post,
        bodyRequired: Bool = true,
        formSubmission: Bool = false
    ) async throws -> T {
        let requestConfiguration = try self.resolveRequestConfiguration(
            apiKey: apiKey,
            configuration: configuration
        )

        if bodyRequired {
            guard let body = body else { throw OpenAIError.noBody }

            if formSubmission {
                let formRequest = FormDataHelper(formUrl: url)

                body.forEach { (key, value) in
                    if let dataValue = value as? FormData {
                        formRequest.addDataField(named: key, formData: dataValue)
                    } else {
                        formRequest.addTextField(named: key, value: "\(value)")
                    }
                }

                var request = formRequest.asURLRequest(headers: requestConfiguration.headers)
                request.timeoutInterval = requestConfiguration.options.timeoutInterval
                let (data, response) = try await self.asyncData(
                    with: request,
                    maxRetries: requestConfiguration.options.maxRetries
                )
                try OpenAIKitSession.validateStatus(response, data: data)

                return try OpenAIKitSession.decodeData(with: data)
            } else {
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                let (data, response) = try await self.asyncData(
                    with: url, method: method,
                    headers: requestConfiguration.headers,
                    body: jsonData,
                    timeoutInterval: requestConfiguration.options.timeoutInterval,
                    maxRetries: requestConfiguration.options.maxRetries
                )
                try OpenAIKitSession.validateStatus(response, data: data)

                return try OpenAIKitSession.decodeData(with: data)
            }
        }

        if !bodyRequired && !formSubmission {
            let (data, response) = try await self.asyncData(
                with: url,
                method: method,
                headers: requestConfiguration.headers,
                timeoutInterval: requestConfiguration.options.timeoutInterval,
                maxRetries: requestConfiguration.options.maxRetries
            )
            try OpenAIKitSession.validateStatus(response, data: data)

            return try OpenAIKitSession.decodeData(with: data)
        }

        throw OpenAIError.noBody
    }
}
