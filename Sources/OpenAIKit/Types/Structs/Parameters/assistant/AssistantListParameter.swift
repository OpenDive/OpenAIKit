//
//  AssistantListParameter.swift
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

public struct AssistantListParameter {
    /// A limit on the number of objects to be returned.
    ///
    /// Limit can range between 1 and 100, and the default is 20.
    public var limit: Int

    /// Sort order by the `created_at` timestamp of the objects.
    ///
    /// `.ascending` for ascending order and `.descending` for descending order.
    public var order: ListOrder

    /// A cursor for use in pagination.
    ///
    /// `after` is an object ID that defines your place in the list. 
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
    public var after: String?

    /// A cursor for use in pagination.
    ///
    /// `before` is an object ID that defines your place in the list. 
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
    public var before: String?

    public init(
        limit: Int = 20,
        order: ListOrder = .descending,
        after: String? = nil,
        before: String? = nil
    ) {
        self.limit = limit
        self.order = order
        self.after = after
        self.before = before
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "limit": self.limit,
            "order": self.order.rawValue
        ]

        if let after = self.after {
            result["after"] = after
        }

        if let before = self.before {
            result["before"] = before
        }

        return result
    }
}
