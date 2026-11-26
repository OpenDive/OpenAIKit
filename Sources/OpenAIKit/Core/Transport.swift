// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Sends HTTP requests for an `OpenAI` client.
///
/// The default is ``URLSessionTransport``. Supply your own to add logging, route requests through
/// another HTTP stack, or return canned responses in tests.
public protocol OpenAIHTTPTransport: Sendable {
    /// Sends a request and returns the whole body.
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)

    /// Sends a request and returns the body as it arrives, in chunks.
    func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse)
}

/// The default transport, built on `URLSession`.
public final class URLSessionTransport: OpenAIHTTPTransport, @unchecked Sendable {
    public let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let response = response as? HTTPURLResponse {
                    continuation.resume(returning: (data ?? Data(), response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            task.resume()
        }
    }

    public func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        #if canImport(FoundationNetworking)
        return try await StreamingDelegate.start(request, configuration: session.configuration)
        #else
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        let stream = AsyncThrowingStream<Data, any Error> { continuation in
            let task = Task {
                do {
                    var buffer = Data()
                    buffer.reserveCapacity(4096)
                    for try await byte in bytes {
                        buffer.append(byte)
                        if byte == 0x0A || buffer.count >= 4096 {
                            continuation.yield(buffer)
                            buffer.removeAll(keepingCapacity: true)
                        }
                    }
                    if !buffer.isEmpty { continuation.yield(buffer) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
        return (stream, http)
        #endif
    }
}

#if canImport(FoundationNetworking)
/// Streams a response body with a delegate, for platforms without `URLSession.bytes(for:)`.
private final class StreamingDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var responseContinuation: CheckedContinuation<HTTPURLResponse, any Error>?
    private var dataContinuation: AsyncThrowingStream<Data, any Error>.Continuation?

    static func start(_ request: URLRequest, configuration: URLSessionConfiguration) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        let delegate = StreamingDelegate()
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        let stream = AsyncThrowingStream<Data, any Error> { continuation in
            delegate.setDataContinuation(continuation)
        }
        let task = session.dataTask(with: request)
        let response = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HTTPURLResponse, any Error>) in
                delegate.setResponseContinuation(continuation)
                task.resume()
            }
        } onCancel: {
            task.cancel()
        }
        delegate.onTermination {
            task.cancel()
            session.finishTasksAndInvalidate()
        }
        return (stream, response)
    }

    private func setDataContinuation(_ continuation: AsyncThrowingStream<Data, any Error>.Continuation) {
        lock.lock()
        dataContinuation = continuation
        lock.unlock()
    }

    private func setResponseContinuation(_ continuation: CheckedContinuation<HTTPURLResponse, any Error>) {
        lock.lock()
        responseContinuation = continuation
        lock.unlock()
    }

    private func onTermination(_ handler: @escaping @Sendable () -> Void) {
        lock.lock()
        dataContinuation?.onTermination = { _ in handler() }
        lock.unlock()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        lock.lock()
        let continuation = responseContinuation
        responseContinuation = nil
        lock.unlock()
        if let http = response as? HTTPURLResponse {
            continuation?.resume(returning: http)
            completionHandler(.allow)
        } else {
            continuation?.resume(throwing: URLError(.badServerResponse))
            completionHandler(.cancel)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        lock.lock()
        let continuation = dataContinuation
        lock.unlock()
        continuation?.yield(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        lock.lock()
        let response = responseContinuation
        responseContinuation = nil
        let data = dataContinuation
        lock.unlock()
        if let error {
            response?.resume(throwing: error)
            data?.finish(throwing: error)
        } else {
            response?.resume(throwing: URLError(.badServerResponse))
            data?.finish()
        }
        session.finishTasksAndInvalidate()
    }
}
#endif
