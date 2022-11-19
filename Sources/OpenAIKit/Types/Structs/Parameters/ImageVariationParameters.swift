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

public struct ImageVariationParameters {
    public var image: FormData
    public var numberOfImages: Int
    public var resolution: ImageResolutions
    public var responseFormat: ResponseFormat
    public var user: String?

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
