//
//  ModelPermission.swift
//  OpenAIKit
//
//  Copyright (c) 2023 MarcoDotIO
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

/// Struct containing permissions associated with the model.
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

    /// The ID of the permission.
    public let id: String

    /// The `OpenAIObject` object type of the permission.
    public let object: OpenAIObject

    /// The creation date of the permission.
    public let created: Int

    /// Does the model allow users to create an engine based on itself?
    public let allowCreateEngine: Bool

    /// Does the model allow sampling?
    public let allowSampling: Bool

    /// Does the model allow the use of `logprobs`?
    public let allowLogprobs: Bool

    /// Does the model allow search indices?
    public let allowSearchIndices: Bool

    /// Is the model viewable?
    public let allowView: Bool

    /// Does the model allow itself to be Fine-tuned?
    public let allowFineTuning: Bool

    /// The organization associated with the permission.
    public let organization: String

    /// The group associated with the permission.
    public let group: String?

    /// Unknown parameter. TODO: Figure out what the parameter means.
    public let isBlocking: Bool
}
