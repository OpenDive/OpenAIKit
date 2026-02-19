import Foundation

/// Parameters for text-to-speech generation.
public struct SpeechParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case input
        case model
        case voice
        case instructions
        case responseFormat = "response_format"
        case speed
        case streamFormat = "stream_format"
    }

    /// Input text to synthesize.
    public var input: String

    /// TTS model identifier.
    public var model: String

    /// Voice identifier.
    public var voice: String

    /// Optional voice instructions.
    public var instructions: String?

    /// Output audio format.
    public var responseFormat: String?

    /// Playback speed multiplier.
    public var speed: Double?

    /// Optional stream format (`audio` or `sse`).
    public var streamFormat: String?

    public init(
        input: String,
        model: String = "gpt-4o-mini-tts",
        voice: String = "alloy",
        instructions: String? = nil,
        responseFormat: String? = nil,
        speed: Double? = nil,
        streamFormat: String? = nil
    ) {
        self.input = input
        self.model = model
        self.voice = voice
        self.instructions = instructions
        self.responseFormat = responseFormat
        self.speed = speed
        self.streamFormat = streamFormat
    }
}
