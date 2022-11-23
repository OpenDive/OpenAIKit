//
//  ImageVariationParameters.swift
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

import SwiftUI

/// Parameter struct used for generating image variation(s).
public struct ImageVariationParameters {
    /// The image to use as the basis for the variation(s).
    ///
    /// Must be a valid PNG file, less than 4MB, and square.
    public var image: FormData

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

    #if os(iOS) || os(tvOS) || os(watchOS)
    public init(
        image: UIImage,
        @Clamped(range: 1...10) numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) throws {
        do {
            guard let imageData = image.pngData() else { throw OpenAIError.invalidData }

            self.image = FormData(data: imageData, mimeType: "image/png", fileName: "image.png")
            self.numberOfImages = numberOfImages
            self.resolution = resolution
            self.responseFormat = responseFormat
            self.user = user
        } catch {
            throw OpenAIError.invalidData
        }
    }
    #endif
    
    #if os(macOS)
    public init(
        image: NSImage,
        @Clamped(range: 1...10) numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) throws {
        do {
            guard let imageData = image.pngData(size: resolution) else { throw OpenAIError.invalidData }

            self.image = FormData(data: imageData, mimeType: "image/png", fileName: "image.png")
            self.numberOfImages = numberOfImages
            self.resolution = resolution
            self.responseFormat = responseFormat
            self.user = user
        } catch {
            throw OpenAIError.invalidData
        }
    }
    #endif
    
    /// The body of the URL used for OpenAI API requests.
    public var body: [String: Any] {
        var result: [String: Any] = ["image": self.image,
                                     "n": self.numberOfImages,
                                     "size": self.resolution.rawValue,
                                     "response_format": self.responseFormat.rawValue]
        if let user = self.user {
            result["user"] = user
        }

        return result
    }
}
