// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// One cue of an SRT or WebVTT transcript, as returned by `client.audio.transcriptions.createText(...)`
/// with `responseFormat` set to `srt` or `vtt`.
public struct SubtitleCue: Codable, Hashable, Sendable {
    /// The cue number (SRT) or identifier (WebVTT), when present.
    public var identifier: String?
    /// Start time as written, for example `00:00:01,000` or `00:00:01.000`.
    public var start: String
    /// End time as written.
    public var end: String
    /// The cue text. Multi-line cues keep their line breaks.
    public var text: String

    public init(identifier: String? = nil, start: String, end: String, text: String) {
        self.identifier = identifier
        self.start = start
        self.end = end
        self.text = text
    }

    /// Start time in seconds.
    public var startSeconds: TimeInterval? { Self.seconds(start) }
    /// End time in seconds.
    public var endSeconds: TimeInterval? { Self.seconds(end) }

    /// Parses SRT or WebVTT text.
    public static func parse(_ text: String) -> [SubtitleCue] {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        var cues: [SubtitleCue] = []
        for block in normalized.components(separatedBy: "\n\n") {
            var lines = block.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
            guard !lines.isEmpty else { continue }
            if lines[0].hasPrefix("WEBVTT") || lines[0].hasPrefix("NOTE") || lines[0].hasPrefix("STYLE") { continue }
            var identifier: String?
            if !lines[0].contains("-->") {
                identifier = lines.removeFirst()
            }
            guard let timing = lines.first, timing.contains("-->") else { continue }
            let times = timing.components(separatedBy: "-->").map { $0.trimmingCharacters(in: .whitespaces) }
            guard times.count == 2 else { continue }
            let end = times[1].split(separator: " ").first.map(String.init) ?? times[1]
            cues.append(SubtitleCue(identifier: identifier, start: times[0], end: end, text: lines.dropFirst().joined(separator: "\n")))
        }
        return cues
    }

    /// Writes cues as SRT.
    public static func srt(_ cues: [SubtitleCue]) -> String {
        cues.enumerated().map { index, cue in
            "\(cue.identifier ?? String(index + 1))\n\(cue.start.replacingOccurrences(of: ".", with: ",")) --> \(cue.end.replacingOccurrences(of: ".", with: ","))\n\(cue.text)"
        }.joined(separator: "\n\n") + "\n"
    }

    /// Writes cues as WebVTT.
    public static func webVTT(_ cues: [SubtitleCue]) -> String {
        "WEBVTT\n\n" + cues.map { cue in
            "\(cue.start.replacingOccurrences(of: ",", with: ".")) --> \(cue.end.replacingOccurrences(of: ",", with: "."))\n\(cue.text)"
        }.joined(separator: "\n\n") + "\n"
    }

    static func seconds(_ time: String) -> TimeInterval? {
        let parts = time.replacingOccurrences(of: ",", with: ".").split(separator: ":")
        guard (2...3).contains(parts.count) else { return nil }
        var total: TimeInterval = 0
        for part in parts {
            guard let value = Double(part) else { return nil }
            total = total * 60 + value
        }
        return total
    }
}
