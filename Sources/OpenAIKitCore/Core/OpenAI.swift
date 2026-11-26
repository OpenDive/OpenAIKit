// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The OpenAIKit version, sent in the `User-Agent` header.
public enum OpenAIKitVersion {
    public static let current = "4.2.0"
}

/// A client for the OpenAI API.
///
/// Operations are grouped the way OpenAI's official SDKs group them:
///
/// ```swift
/// let client = OpenAI(Configuration(apiKey: "sk-..."))
/// let response = try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hello"))
/// print(response.outputText)
/// ```
///
/// The client is a cheap, thread-safe value holder. Share one instance across your app.
public final class OpenAI: Sendable {
    public let configuration: Configuration
    public let transport: any OpenAIHTTPTransport

    public init(_ configuration: Configuration, transport: (any OpenAIHTTPTransport)? = nil) {
        self.configuration = configuration
        self.transport = transport ?? URLSessionTransport()
    }

    /// A client with just an API key.
    public convenience init(apiKey: String) {
        self.init(Configuration(apiKey: apiKey))
    }

    // MARK: Sending

    /// Sends a request and decodes a JSON response.
    public func perform<T: Decodable>(_ request: OpenAIRequest, options: OpenAIRequestOptions? = nil, as type: T.Type = T.self) async throws -> T {
        let data = try await performData(request, options: options)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw OpenAIError.decoding(type: String(describing: T.self), underlying: error, body: data)
        }
    }

    /// Sends a request and returns the raw response body.
    public func performData(_ request: OpenAIRequest, options: OpenAIRequestOptions? = nil) async throws -> Data {
        let resolved = configuration.requestOptions.merging(options)
        let urlRequest = try makeURLRequest(request, options: resolved)
        var attempt = 0
        while true {
            do {
                let (data, response) = try await transport.send(urlRequest)
                if (200...299).contains(response.statusCode) {
                    return data
                }
                let headers = Self.headers(of: response)
                if attempt < resolved.resolvedMaxRetries, Self.shouldRetry(status: response.statusCode, headers: headers) {
                    try await Self.sleep(beforeRetry: attempt, maxRetries: resolved.resolvedMaxRetries, headers: headers)
                    attempt += 1
                    continue
                }
                throw OpenAIAPIError(statusCode: response.statusCode, body: data, headers: headers)
            } catch let error as URLError {
                if error.code == .cancelled || Task.isCancelled { throw CancellationError() }
                if attempt < resolved.resolvedMaxRetries, Self.isRetryable(error) {
                    try await Self.sleep(beforeRetry: attempt, maxRetries: resolved.resolvedMaxRetries, headers: [:])
                    attempt += 1
                    continue
                }
                throw error.code == .timedOut ? OpenAIError.timeout : OpenAIError.connection(error)
            }
        }
    }

    /// Sends a request and decodes its server-sent events.
    ///
    /// - Parameters:
    ///   - wrapped: Wrap each event as `{"event": name, "data": payload}` before decoding.
    ///     The Assistants API streams events this way.
    ///   - type: The event type to decode.
    ///   - make: Builds the request. Errors it throws end the stream.
    public func stream<Event: Decodable & Sendable>(
        wrapped: Bool = false,
        as type: Event.Type,
        _ make: @escaping @Sendable () throws -> (OpenAIRequest, OpenAIRequestOptions?)
    ) -> AsyncThrowingStream<Event, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (request, options) = try make()
                    let resolved = self.configuration.requestOptions.merging(options)
                    var urlRequest = try self.makeURLRequest(request, options: resolved)
                    urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    let chunks = try await self.openStream(urlRequest, options: resolved)
                    var parser = ServerSentEventParser()
                    let decoder = JSONDecoder()
                    func handle(_ event: ServerSentEvent) throws -> Bool {
                        let data = event.dataBytes
                        if data.isEmpty { return true }
                        if Self.isDone(data) { return false }
                        // Like the official SDKs: a payload whose top level is an `error` object ends the
                        // stream with an error. Typed error events (Responses `type: "error"`) are yielded.
                        if Self.startsWithErrorKey(data) {
                            throw OpenAIAPIError(statusCode: 0, body: data, headers: [:])
                        }
                        let payload = wrapped ? Self.wrap(data, event: event.event) : data
                        do {
                            continuation.yield(try decoder.decode(Event.self, from: payload))
                        } catch {
                            throw OpenAIError.decoding(type: String(describing: Event.self), underlying: error, body: payload)
                        }
                        return true
                    }
                    streaming: for try await chunk in chunks {
                        for event in parser.feed(chunk) {
                            if try !handle(event) { break streaming }
                        }
                    }
                    for event in parser.finish() {
                        if try !handle(event) { break }
                    }
                    continuation.finish()
                } catch let error as URLError {
                    if error.code == .cancelled || Task.isCancelled {
                        continuation.finish(throwing: CancellationError())
                        return
                    }
                    continuation.finish(throwing: error.code == .timedOut ? OpenAIError.timeout : OpenAIError.connection(error))
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static let errorKey = Data("\"error\"".utf8)

    static func isDone(_ data: Data) -> Bool {
        guard data.count < 16, data.contains(0x5B) else { return false }
        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]"
    }

    /// Whether the payload is a JSON object whose first key is `"error"`, checked without parsing it.
    static func startsWithErrorKey(_ data: Data) -> Bool {
        var index = data.startIndex
        func skipWhitespace() {
            while index < data.endIndex, data[index] == 0x20 || data[index] == 0x0A || data[index] == 0x0D || data[index] == 0x09 {
                index += 1
            }
        }
        skipWhitespace()
        guard index < data.endIndex, data[index] == 0x7B else { return false }
        index += 1
        skipWhitespace()
        guard data.endIndex - index >= errorKey.count else { return false }
        return data[index..<(index + errorKey.count)].elementsEqual(errorKey)
    }

    /// `{"event": <name>, "data": <payload>}` built from bytes, without re-encoding the payload.
    static func wrap(_ data: Data, event: String?) -> Data {
        guard let event else { return data }
        var wrapped = Data("{\"event\":".utf8)
        wrapped.append((try? JSONEncoder().encode(event)) ?? Data("\"\"".utf8))
        wrapped.append(Data(",\"data\":".utf8))
        wrapped.append(data)
        wrapped.append(0x7D)
        return wrapped
    }

    private func openStream(_ urlRequest: URLRequest, options: OpenAIRequestOptions) async throws -> AsyncThrowingStream<Data, any Error> {
        var attempt = 0
        while true {
            do {
                let (chunks, response) = try await transport.stream(urlRequest)
                if (200...299).contains(response.statusCode) {
                    return chunks
                }
                var body = Data()
                for try await chunk in chunks { body.append(chunk) }
                let headers = Self.headers(of: response)
                if attempt < options.resolvedMaxRetries, Self.shouldRetry(status: response.statusCode, headers: headers) {
                    try await Self.sleep(beforeRetry: attempt, maxRetries: options.resolvedMaxRetries, headers: headers)
                    attempt += 1
                    continue
                }
                throw OpenAIAPIError(statusCode: response.statusCode, body: body, headers: headers)
            } catch let error as URLError {
                if error.code == .cancelled || Task.isCancelled { throw CancellationError() }
                if attempt < options.resolvedMaxRetries, Self.isRetryable(error) {
                    try await Self.sleep(beforeRetry: attempt, maxRetries: options.resolvedMaxRetries, headers: [:])
                    attempt += 1
                    continue
                }
                throw error
            }
        }
    }

    // MARK: Building requests

    /// Turns an `OpenAIRequest` into a `URLRequest` with credentials and default headers.
    public func makeURLRequest(_ request: OpenAIRequest, options: OpenAIRequestOptions? = nil) throws -> URLRequest {
        let options = configuration.requestOptions.merging(options)
        var base = configuration.baseURL.absoluteString
        while base.hasSuffix("/") { base.removeLast() }
        guard var components = URLComponents(string: base + request.path) else {
            throw OpenAIError.invalidURL(base + request.path)
        }
        var query = request.query
        for (name, value) in options.additionalQuery.sorted(by: { $0.key < $1.key }) {
            query.append(URLQueryItem(name: name, value: value))
        }
        if !query.isEmpty {
            components.percentEncodedQuery = query.map { item in
                "\(Self.queryEscape(item.name))=\(Self.queryEscape(item.value ?? ""))"
            }.joined(separator: "&")
        }
        guard let url = components.url else {
            throw OpenAIError.invalidURL(base + request.path)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.timeoutInterval = options.resolvedTimeout

        switch request.authentication {
        case .apiKey:
            if let key = configuration.apiKey, !key.isEmpty {
                urlRequest.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            } else if configuration.talksToOpenAIDirectly {
                throw OpenAIError.missingAPIKey
            }
        case .admin:
            if let key = configuration.adminAPIKey, !key.isEmpty {
                urlRequest.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            } else if configuration.talksToOpenAIDirectly {
                throw OpenAIError.missingAdminAPIKey
            }
        }
        if let organization = configuration.organizationId, !organization.isEmpty {
            urlRequest.setValue(organization, forHTTPHeaderField: "OpenAI-Organization")
        }
        if let project = configuration.projectId, !project.isEmpty {
            urlRequest.setValue(project, forHTTPHeaderField: "OpenAI-Project")
        }
        urlRequest.setValue("OpenAIKit/\(OpenAIKitVersion.current) (Swift)", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        switch request.body {
        case .none:
            break
        case .json(let data):
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
        case .multipart(let parts):
            let boundary = "OpenAIKit-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = MultipartPart.encode(parts, boundary: boundary)
        case .raw(let data, let contentType):
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
        }
        for (name, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        for (name, value) in options.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        return urlRequest
    }

    private static func queryEscape(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+?#")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    // MARK: Retries

    static func headers(of response: HTTPURLResponse) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            headers[String(describing: key).lowercased()] = String(describing: value)
        }
        return headers
    }

    static func shouldRetry(status: Int, headers: [String: String]) -> Bool {
        if let header = headers["x-should-retry"] {
            if header == "true" { return true }
            if header == "false" { return false }
        }
        if let delay = retryAfter(headers), delay > maxRetryAfter { return false }
        return status == 408 || status == 409 || status == 429 || status >= 500
    }

    static func isRetryable(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost,
             .dnsLookupFailed, .notConnectedToInternet, .resourceUnavailable, .secureConnectionFailed:
            return true
        default:
            return false
        }
    }

    static let maxRetryAfter: TimeInterval = 120

    static func retryAfter(_ headers: [String: String]) -> TimeInterval? {
        if let ms = headers["retry-after-ms"].flatMap(Double.init) { return ms / 1000 }
        if let raw = headers["retry-after"] {
            if let seconds = Double(raw) { return seconds }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            if let date = formatter.date(from: raw) { return date.timeIntervalSinceNow }
        }
        return nil
    }

    /// Exponential backoff from 0.5 s to 8 s with up to 25% jitter, or the server's `retry-after`.
    static func retryDelay(attempt: Int, headers: [String: String]) -> TimeInterval {
        if let delay = retryAfter(headers), delay > 0, delay <= maxRetryAfter {
            return delay
        }
        let base = min(0.5 * pow(2.0, Double(min(attempt, 30))), 8.0)
        return base * (1 - 0.25 * Double.random(in: 0...1))
    }

    private static func sleep(beforeRetry attempt: Int, maxRetries: Int, headers: [String: String]) async throws {
        let delay = retryDelay(attempt: attempt, headers: headers)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
