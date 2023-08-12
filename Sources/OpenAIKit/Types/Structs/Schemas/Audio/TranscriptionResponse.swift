//
//  TranscriptionResponse.swift
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

public struct TranscriptionResponse: Codable {
    /// The text content of the transcription
    public let text: String?

    /// What type of task was performed (transcribe or translate)
    public let task: String?

    /// What language was the audio in
    public let language: String?

    /// The duration of the audio source
    public let duration: Double?

    /// Transcription details on each sentence
    public let segments: [TranscriptionSegment]?

    /// The WebVTT formatted text
    public let vtt: [WebVTTCue]?

    /// The SRT formatted text
    public let srt: [SRT]?

    public init(
        text: String? = nil,
        task: String? = nil,
        language: String? = nil,
        duration: Double? = nil,
        segments: [TranscriptionSegment]? = nil,
        vtt: [WebVTTCue]? = nil,
        srt: [SRT]? = nil
    ) {
        self.text = text
        self.task = task
        self.language = language
        self.duration = duration
        self.segments = segments
        self.vtt = vtt
        self.srt = srt
    }
}

public struct TranscriptionSegment: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case seek
        case start
        case end
        case text
        case tokens
        case temperature
        case averageLogprob = "avg_logprob"
        case compressionRatio = "compression_ratio"
        case noSpeechProb = "no_speech_prob"
    }

    public let id: Int
    public let seek: Int
    public let start: Double
    public let end: Double
    public let text: String
    public let tokens: [Int]
    public let temperature: Double
    public let averageLogprob: Double
    public let compressionRatio: Double
    public let noSpeechProb: Double
}
