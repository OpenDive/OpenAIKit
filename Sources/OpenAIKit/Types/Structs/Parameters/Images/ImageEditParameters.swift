//
//  ImageEditParameters.swift
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

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import SwiftUI
#endif

#if os(macOS)
import Foundation
import AppKit
#endif

#if os(Linux) || SERVER
import Foundation
#endif

/// Parameter used for creating image edits
public struct ImageEditParameters {
    /// The image to edit.
    ///
    /// Must be a valid PNG file, less than 4MB, and square. If mask is not provided,
    /// image must have transparency, which will be used as the mask.
    public var image: FormData

    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where `image` should be edited.
    ///
    /// Must be a valid PNG file, less than 4MB, and have the same dimensions as `image`.
    public var mask: FormData

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
        image: Data,
        mask: Data,
        prompt: String,
        @Clamped(range: 1...10) numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) throws {
        self.image = FormData(data: image, mimeType: "image/png", fileName: "image.png")
        self.mask = FormData(data: mask, mimeType: "image/png", fileName: "mask.png")
        self.prompt = prompt
        self.numberOfImages = numberOfImages
        self.resolution = resolution
        self.responseFormat = responseFormat
        self.user = user
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
    public init(
        image: UIImage,
        mask: UIImage,
        prompt: String,
        @Clamped(range: 1...10) numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) throws {
        do {
            guard let imageData = image.pngData() else { throw OpenAIError.invalidData }
            guard let maskData = mask.pngData() else { throw OpenAIError.invalidData }

            self.image = FormData(data: imageData, mimeType: "image/png", fileName: "image.png")
            self.mask = FormData(data: maskData, mimeType: "image/png", fileName: "mask.png")
            self.prompt = prompt
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
        mask: NSImage,
        prompt: String,
        @Clamped(range: 1...10) numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) throws {
        do {
            guard let imageData = image.pngData(size: resolution) else { throw OpenAIError.invalidData }
            guard let maskData = mask.pngData(size: resolution) else { throw OpenAIError.invalidData }

            self.image = FormData(data: imageData, mimeType: "image/png", fileName: "image.png")
            self.mask = FormData(data: maskData, mimeType: "image/png", fileName: "mask.png")
            self.prompt = prompt
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
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "image": self.image,
            "mask": self.mask,
            "prompt": self.prompt,
            "n": self.numberOfImages,
            "size": self.resolution.rawValue,
            "response_format": self.responseFormat.rawValue
        ]
        if let user = self.user {
            result["user"] = user
        }

        return result
    }
}
