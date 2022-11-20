//
//  File.swift
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

/// The file object used to read file information from the Files endpoint.
public struct File: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case bytes
        case createdAt = "created_at"
        case filename
        case purpose
        case status
        case statusDetails = "status_details"
    }

    /// The ID of the file.
    public let id: String

    /// The `OpenAIObject` object type of the file.
    public let object: OpenAIObject

    /// The amount of storage the file takes up in bytes.
    public let bytes: Int

    /// The creation date of the file.
    public let createdAt: Int

    /// The file's name.
    public let filename: String

    /// The purpose the file has. Usually is "fine-tune".
    public let purpose: String

    /// The upload status of the file.
    public let status: FileStatus?

    /// The status detail when uploading the file.
    public let statusDetails: String?
}
