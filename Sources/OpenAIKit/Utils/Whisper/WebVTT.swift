//
//  WebVTTCue.swift
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

import Foundation

public struct WebVTTCue: Codable {
    public let startTime: String
    public let endTime: String
    public let text: String

    public static func parseWebVTT(from input: String) -> [WebVTTCue] {
        var cues: [WebVTTCue] = []
        let lines = input.split(separator: "\n")
        var index = 0

        // Skip the "WEBVTT" header
        if lines.count > 0 && lines[0] == "WEBVTT" {
            index += 1
        }

        while index < lines.count {
            let timeRange = lines[index].components(separatedBy: " --> ")
            if timeRange.count == 2 {
                let startTime = String(timeRange[0])
                let endTime = String(timeRange[1])

                index += 1
                var text = ""
                while index < lines.count && !lines[index].isEmpty {
                    text += (text.isEmpty ? "" : "\n") + lines[index]
                    index += 1
                }

                let cue = WebVTTCue(startTime: startTime, endTime: endTime, text: text)
                cues.append(cue)
            }

            index += 1
        }

        return cues
    }

    public static func exportCuesToWebVTT(_ cues: [WebVTTCue]) -> String {
        var output = "WEBVTT\n\n"
        for cue in cues {
            output += "\(cue.startTime) --> \(cue.endTime)\n"
            output += cue.text + "\n\n"
        }
        return output
    }
}
