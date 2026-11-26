// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// Every item of a paginated list, fetched one page at a time as you iterate.
///
/// ```swift
/// for try await file in client.files.listAll(limit: 100) {
///     print(file.id)
/// }
/// ```
public struct OpenAIAutoPagingSequence<Element: Sendable>: AsyncSequence, Sendable {
    public typealias FetchPage = @Sendable (_ cursor: String?) async throws -> (items: [Element], next: String?)

    private let fetch: FetchPage
    private let start: String?

    /// - Parameters:
    ///   - start: The cursor of the first page, or `nil` for the beginning.
    ///   - fetch: Loads one page and returns its items and the cursor of the next page, or `nil` after the last page.
    public init(start: String? = nil, fetch: @escaping FetchPage) {
        self.start = start
        self.fetch = fetch
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(fetch: fetch, cursor: start)
    }

    public struct Iterator: AsyncIteratorProtocol {
        let fetch: FetchPage
        var cursor: String?
        var buffer: [Element] = []
        var index = 0
        var finished = false

        init(fetch: @escaping FetchPage, cursor: String?) {
            self.fetch = fetch
            self.cursor = cursor
        }

        public mutating func next() async throws -> Element? {
            while index >= buffer.count {
                if finished { return nil }
                let page = try await fetch(cursor)
                buffer = page.items
                index = 0
                if let next = page.next, next != cursor, !page.items.isEmpty {
                    cursor = next
                } else {
                    finished = true
                }
            }
            defer { index += 1 }
            return buffer[index]
        }
    }

    /// Collects every item into an array. Avoid this for lists that may be very long.
    public func collect() async throws -> [Element] {
        var all: [Element] = []
        for try await element in self { all.append(element) }
        return all
    }
}

/// A list response with a `data` array, such as `ListFilesResponse`.
public protocol OpenAIPage: Sendable {
    associatedtype Item: Sendable
    var data: [Item] { get }
}
