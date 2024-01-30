//
//  ImageParameters.swift
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
    /// Must be one of `.small`, `.medium`, `.large` for `.dalle2`. Must be one of `.large`, `.extraLargeLandscape`, or `.extraLargePortrait` for `.dalle3`.
    public var resolution: ImageResolutions

    /// The quality of the image that will be generated.
    ///
    /// `hd` creates images with finer details and greater consistency across the image.
    ///
    /// **Note:** This param is only supported for dall-e-3.
    public var quality: ImageQuality?

    /// The model to use for image generation.
    public var model: ImageModel

    /// The style of the generated images.
    ///
    /// Must be one of vivid or natural. Vivid causes the model to lean towards generating hyper-real and dramatic images. Natural causes the model to produce more natural, less hyper-real looking images.
    ///
    /// **Note:** This param is only supported for dall-e-3.
    public var style: ImageStyle?

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
        quality: ImageQuality? = nil,
        style: ImageStyle? = nil,
        model: ImageModel = .dalle2,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.numberOfImages = numberofImages
        self.resolution = resolution
        self.quality = quality
        self.style = style
        self.model = model
        self.responseFormat = responseFormat
        self.user = user
    }

    /// Checks to verify that the user hasn't inputted any incorrect parameters for the endpoint.
    /// - Throws: An `OpenAIError` if any of the parameters are incompatible with the inputted model.
    internal func checkForCompatibility() throws {
        switch self.model {
        case .dalle2:
            guard self.prompt.count <= 1_000 else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.prompt) }
            guard self.quality == nil else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.quality) }
            guard self.style == nil else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.style) }
            guard 
                self.resolution == .small ||
                self.resolution == .medium ||
                self.resolution == .large
            else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.resolution) }
        case .dalle3:
            guard self.prompt.count <= 4_000 else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.prompt) }
            guard self.numberOfImages == 1 else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.numberOfImages) }
            guard
                self.resolution == .large ||
                self.resolution == .extraLargePortrait ||
                self.resolution == .extraLargeLandscape
            else { throw OpenAIError.incompatibleImageParameter(incorrctInput: self.resolution) }
        }
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "prompt": self.prompt,
            "n": self.numberOfImages,
            "size": self.resolution.rawValue,
            "response_format": self.responseFormat.rawValue,
            "model": self.model.rawValue
        ]

        if let quality = self.quality {
            result["quality"] = quality.rawValue
        }

        if let style = self.style {
            result["style"] = style.rawValue
        }

        if let user = self.user {
            result["user"] = user
        }

        return result
    }
}
