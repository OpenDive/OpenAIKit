//
//  ImageParameters.swift
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

/// Parameter used for generating images given a prompt.
public struct ImageParameters {
    /// A text description of the desired image(s).
    ///
    /// The maximum length is 1000 characters.
    public var prompt: String

    /// The number of images to generate.
    ///
    /// Must be between 1 and 10.
    public var numberOfImages: Int

    /// The size of the generated images.
    ///
    /// Must be one of `.small`, `.medium`, or `.large`.
    public var resolution: ImageResolutions

    /// The format in which the generated images are returned.
    ///
    /// Must be one of `url` or `b64_json`.
    public var responseFormat: ResponseFormat

    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// [Learn more.](https://beta.openai.com/docs/guides/safety-best-practices/end-user-ids)
    public var user: String?

    public init(
        prompt: String,
        @Clamped(range: 1...10) numberofImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.numberOfImages = numberofImages
        self.resolution = resolution
        self.responseFormat = responseFormat
        self.user = user
    }

    /// The body of the URL used for OpenAI API requests.
    public var body: [String: Any] {
        var result: [String: Any] = ["prompt": self.prompt,
                                     "n": self.numberOfImages,
                                     "size": self.resolution.rawValue,
                                     "response_format": self.responseFormat.rawValue]
        if let user = self.user {
            result["user"] = user
        }

        return result
    }
}
