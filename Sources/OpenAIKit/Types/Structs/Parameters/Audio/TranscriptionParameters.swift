//
//  TranscriptionParameters.swift
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

public struct TranscriptionParameters {
    /// The audio file object (not file name) translate, in one of these formats: mp3, mp4, mpeg, mpga, m4a, wav, or webm.
    public var file: FormData

    /// ID of the model to use. Only `whisper-1` is currently available.
    public var model: String

    /// An optional text to guide the model's style or continue a previous audio segment. 
    /// The [prompt](https://platform.openai.com/docs/guides/speech-to-text/prompting) should be in English.
    public var prompt: String?

    /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
    public var responseFormat: AudioResponseFormat

    /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. 
    /// If set to 0, the model will use [log probability](https://en.wikipedia.org/wiki/Log_probability) to automatically increase the temperature until certain thresholds are hit.
    public var temperature: Double

    /// The language of the input audio. Supplying the input language in 
    /// [ISO-639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) format will improve accuracy and latency.
    public var language: String?

    public init(
        file: Data,
        model: String = "whisper-1",
        prompt: String? = nil,
        responseFormat: AudioResponseFormat = .json,
        @Clamped(range: 0...1) temperature: Double = 0.0,
        language: String? = nil
    ) {
        self.file = FormData(data: file, mimeType: "audio/mpeg", fileName: "audio.mp3")
        self.model = model
        self.prompt = prompt
        self.responseFormat = responseFormat
        self.temperature = temperature
        self.language = language
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "file": self.file,
            "model": self.model,
            "response_format": self.responseFormat.rawValue,
            "temperature": self.temperature
        ]

        if let prompt = prompt {
            result["prompt"] = prompt
        }

        if let language = language {
            result["language"] = language
        }

        return result
    }

    /// Retrieve the Response object for the request
    /// - Parameters:
    ///   - url: The `URL` of the request endpoint
    ///   - config: The configuration options for OpenAI's API
    /// - Returns: A `TransactionResponse` object.
    internal func retrieveResponse(using url: URL, _ config: Configuration) async throws -> TranscriptionResponse {
        switch self.responseFormat {
        case .json, .verboseJson:
            return try await OpenAIKitSession.shared.decodeUrl(
                with: url,
                apiKey: config.apiKey,
                body: self.body,
                formSubmission: true
            )
        case .text:
            let data = try await OpenAIKitSession.shared.decodeUrlTranscriptions(
                with: url,
                apiKey: config.apiKey,
                body: self.body
            )
            return TranscriptionResponse(text: String(decoding: data, as: UTF8.self))
        case .srt:
            let data = try await OpenAIKitSession.shared.decodeUrlTranscriptions(
                with: url,
                apiKey: config.apiKey,
                body: self.body
            )
            return TranscriptionResponse(srt: SRT.parseSRT(from: String(decoding: data, as: UTF8.self)))
        case .vtt:
            let data = try await OpenAIKitSession.shared.decodeUrlTranscriptions(
                with: url,
                apiKey: config.apiKey,
                body: self.body
            )
            return TranscriptionResponse(vtt: WebVTTCue.parseWebVTT(from: String(decoding: data, as: UTF8.self)))
        }
    }
}
