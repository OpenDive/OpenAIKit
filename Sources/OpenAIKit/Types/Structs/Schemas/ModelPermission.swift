//
//  ModelPermission.swift
//  OpenAIKit
//
//  Copyright (c) 2022 MarcoDotIO
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

public struct ModelPermission: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case allowCreateEngine = "allow_create_engine"
        case allowSampling = "allow_sampling"
        case allowLogprobs = "allow_logprobs"
        case allowSearchIndices = "allow_search_indices"
        case allowView = "allow_view"
        case allowFineTuning = "allow_fine_tuning"
        case organization
        case group
        case isBlocking = "is_blocking"
    }

    public let id: String
    public let object: OpenAIObject
    public let created: Int
    public let allowCreateEngine: Bool
    public let allowSampling: Bool
    public let allowLogprobs: Bool
    public let allowSearchIndices: Bool
    public let allowView: Bool
    public let allowFineTuning: Bool
    public let organization: String
    public let group: String?
    public let isBlocking: Bool
}
