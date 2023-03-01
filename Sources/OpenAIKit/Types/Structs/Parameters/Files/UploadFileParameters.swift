//
//  UploadFileParameters.swift
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

import Foundation

/// Parameter used for uploading files.
public struct UploadFileParameters {
    /// Name of the [JSON Lines](https://jsonlines.readthedocs.io/en/latest/) file to be uploaded.
    ///
    /// If the `purpose` is set to "fine-tune", each line is a JSON record with "prompt" and "completion" fields
    /// representing your [training examples](https://beta.openai.com/docs/guides/fine-tuning/prepare-training-data).
    public var file: FormData

    /// The intended purpose of the uploaded documents.
    ///
    /// Use "fine-tune" for [Fine-tuning](https://beta.openai.com/docs/api-reference/fine-tunes).
    /// This allows us to validate the format of the uploaded file.
    public var purpose: String

    public init(
        file: Data,
        fileName: String,
        purpose: String
    ) {
        self.file = FormData(data: file, mimeType: "application/octet-stream", fileName: fileName)
        self.purpose = purpose
    }

    public var body: [String: Any] {
        return ["file": self.file, "purpose": self.purpose]
    }
}
