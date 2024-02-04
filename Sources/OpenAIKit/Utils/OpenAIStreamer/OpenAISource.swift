//
//  OpenAISource.swift
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

public enum OpenAISourceState {
    case connecting
    case open
    case closed
}

public struct Message {
    public let id: String?
    public let event: String?
    public let data: String?
}

open class OpenAISource: NSObject, URLSessionDataDelegate {
    var headers: [String: String]
    static let DefaultRetryTime = 3000

    public let url: URLRequest
    private(set) public var lastEventId: String?
    private(set) public var retryTime = OpenAISource.DefaultRetryTime
    private(set) public var readyState: OpenAISourceState

    private var onOpenCallback: (() -> Void)?
    private var onComplete: ((Int?, Bool?, NSError?) -> Void)?
    private var onMessageCallback: ((Message) -> Void)?
    private var eventListeners: [String: (Message) -> Void] = [:]

    private var openAiStreamParser: OpenAIStreamParser?
    private var operationQueue: OperationQueue
    private var mainQueue = DispatchQueue.main
    private var urlSession: URLSession?

    public init(url: URLRequest) {
        self.url = url
        self.headers = url.allHTTPHeaderFields ?? [:]
        
        self.readyState = .closed
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        
        super.init()
    }

    public func connect(lastEventId: String? = nil) {
        self.openAiStreamParser = OpenAIStreamParser()
        self.readyState = .connecting

        let configuration = self.sessionConfiguration(lastEventId: lastEventId)
        self.urlSession = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: self.operationQueue
        )
        self.urlSession?
            .dataTask(with: self.url)
            .resume()
    }

    public func disconnect() {
        self.readyState = .closed
        self.urlSession?.invalidateAndCancel()
    }

    public func onOpen(_ onOpenCallback: @escaping (() -> Void)) {
        self.onOpenCallback = onOpenCallback
    }

    public func onComplete(_ onComplete: @escaping ((Int?, Bool?, NSError?) -> Void)) {
        self.onComplete = onComplete
    }

    public func onMessage(_ onMessageCallback: @escaping ((Message) -> Void)) {
        self.onMessageCallback = onMessageCallback
    }

    public func addEventListener(_ event: String,
                                 handler: @escaping ((Message) -> Void)) {
        self.eventListeners[event] = handler
    }

    public func removeEventListener(_ event: String) {
        self.eventListeners.removeValue(forKey: event)
    }

    public func events() -> [String] {
        return Array(self.eventListeners.keys)
    }

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.readyState != .open {
            return
        }

        if let events = self.openAiStreamParser?.append(data: data) {
            self.notifyReceivedEvents(events)
        }
    }

    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        completionHandler(URLSession.ResponseDisposition.allow)
        self.readyState = .open
        self.mainQueue.async { [weak self] in self?.onOpenCallback?() }
    }

    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let responseStatusCode = (task.response as? HTTPURLResponse)?.statusCode else {
            mainQueue.async { [weak self] in self?.onComplete?(nil, nil, error as NSError?) }
            return
        }

        let reconnect = shouldReconnect(statusCode: responseStatusCode)
        mainQueue.async { [weak self] in self?.onComplete?(responseStatusCode, reconnect, nil) }
    }

    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        var newRequest = request
        self.headers.forEach { newRequest.setValue($1, forHTTPHeaderField: $0) }
        completionHandler(newRequest)
    }
}

internal extension OpenAISource {
    func sessionConfiguration(lastEventId: String?) -> URLSessionConfiguration {
        var additionalHeaders = headers
        if let eventID = lastEventId {
            additionalHeaders["Last-Event-Id"] = eventID
        }

        additionalHeaders["Accept"] = "text/event-stream"
        additionalHeaders["Cache-Control"] = "no-cache"

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        sessionConfiguration.httpAdditionalHeaders = additionalHeaders

        return sessionConfiguration
    }

    func readyStateOpen() {
        self.readyState = .open
    }
}

private extension OpenAISource {
    func notifyReceivedEvents(_ events: [OpenAIEvent]) {
        for event in events {
            lastEventId = event.id
            retryTime = event.retryTime ?? OpenAISource.DefaultRetryTime

            if event.onlyRetryEvent == true {
                continue
            }

            if event.event == nil || event.event == "message" {
                mainQueue.async { [weak self] in
                    self?.onMessageCallback?(Message(id: event.id, event: "message", data: event.data))
                }
            }

            if let eventName = event.event, let eventHandler = eventListeners[eventName] {
                mainQueue.async {
                    eventHandler(Message(id: event.id, event: event.event, data: event.data))
                }
            }
        }
    }

    // Following "5 Processing model" from:
    // https://www.w3.org/TR/2009/WD-eventsource-20090421/#handler-eventsource-onerror
    func shouldReconnect(statusCode: Int) -> Bool {
        switch statusCode {
        case 200:
            return false
        case _ where statusCode > 200 && statusCode < 300:
            return true
        default:
            return false
        }
    }
}

public extension OpenAISource {
    func streamData<T: Decodable>() -> AsyncThrowingStream<T, Error> {
        return AsyncThrowingStream { continuation in
            let connection = OpenAISource(url: self.url)

            connection.onMessageCallback = { message in
                guard let messageData = message.data, messageData != "[DONE]"
                else { return message.data == nil ? continuation.finish(throwing: OpenAIError.invalidData) : continuation.finish() }
                do { continuation.yield(try OpenAIKitSession.decodeData(T.self, with: Data(messageData.utf8))) }
                catch { continuation.finish(throwing: error) }
            }

            continuation.onTermination = { @Sendable _ in
                connection.disconnect()
            }

            connection.connect()
        }
    }
}
