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
    private let router: StreamRouter
    /// A session with the same configuration whose delegate delivers streamed bodies chunk by chunk.
    private let streamingSession: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
        let router = StreamRouter()
        let queue = OperationQueue()
        queue.name = "OpenAIKit.URLSessionTransport.stream"
        queue.maxConcurrentOperationCount = 1
        self.router = router
        self.streamingSession = URLSession(configuration: session.configuration, delegate: router, delegateQueue: queue)
    }

    deinit {
        streamingSession.finishTasksAndInvalidate()
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let handle = CancellableTask()
        return try await withTaskCancellationHandler {
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
                handle.start(task)
            }
        } onCancel: {
            handle.cancel()
        }
    }

    /// Streams the body as `URLSession` receives it: one chunk per network read, with no per-byte work.
    public func stream(_ request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        try await router.start(request, on: streamingSession)
    }
}

/// Routes delegate callbacks of a shared streaming session to each task's stream.
private final class StreamRouter: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private struct Route {
        var response: CheckedContinuation<HTTPURLResponse, any Error>?
        var data: AsyncThrowingStream<Data, any Error>.Continuation?
    }

    private let lock = NSLock()
    private var routes: [Int: Route] = [:]

    func start(_ request: URLRequest, on session: URLSession) async throws -> (AsyncThrowingStream<Data, any Error>, HTTPURLResponse) {
        let task = session.dataTask(with: request)
        let id = task.taskIdentifier
        let stream = AsyncThrowingStream<Data, any Error>(bufferingPolicy: .unbounded) { continuation in
            self.update(id) { $0.data = continuation }
            continuation.onTermination = { _ in task.cancel() }
        }
        let handle = CancellableTask()
        let response = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HTTPURLResponse, any Error>) in
                self.update(id) { $0.response = continuation }
                handle.start(task)
            }
        } onCancel: {
            handle.cancel()
        }
        return (stream, response)
    }

    private func update(_ id: Int, _ change: (inout Route) -> Void) {
        lock.lock()
        var route = routes[id] ?? Route()
        change(&route)
        routes[id] = route
        lock.unlock()
    }

    private func take(_ id: Int, response: Bool) -> CheckedContinuation<HTTPURLResponse, any Error>? {
        lock.lock(); defer { lock.unlock() }
        guard response else { return nil }
        let continuation = routes[id]?.response
        routes[id]?.response = nil
        return continuation
    }

    private func dataContinuation(_ id: Int) -> AsyncThrowingStream<Data, any Error>.Continuation? {
        lock.lock(); defer { lock.unlock() }
        return routes[id]?.data
    }

    private func remove(_ id: Int) -> Route? {
        lock.lock(); defer { lock.unlock() }
        return routes.removeValue(forKey: id)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let continuation = take(dataTask.taskIdentifier, response: true)
        if let http = response as? HTTPURLResponse {
            continuation?.resume(returning: http)
            completionHandler(.allow)
        } else {
            continuation?.resume(throwing: URLError(.badServerResponse))
            completionHandler(.cancel)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataContinuation(dataTask.taskIdentifier)?.yield(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let route = remove(task.taskIdentifier) else { return }
        if let error {
            route.response?.resume(throwing: error)
            route.data?.finish(throwing: error)
        } else {
            route.response?.resume(throwing: URLError(.badServerResponse))
            route.data?.finish()
        }
    }
}

/// Cancels a `URLSessionTask` when the Swift task that started it is cancelled, even if
/// cancellation arrives before the task starts.
private final class CancellableTask: @unchecked Sendable {
    private let lock = NSLock()
    private var task: URLSessionTask?
    private var cancelled = false

    func start(_ task: URLSessionTask) {
        lock.lock()
        self.task = task
        let cancelled = self.cancelled
        lock.unlock()
        if cancelled { task.cancel() } else { task.resume() }
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let task = self.task
        lock.unlock()
        task?.cancel()
    }
}
