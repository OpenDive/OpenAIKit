//
//  SRT.swift
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

public struct SRT: Codable {
    public let id: Int
    public let start: String
    public let end: String
    public let content: String

    public static func parseSRT(from input: String) -> [SRT] {
        let lines = input.split(separator: "\n").map(String.init)
        var subtitles: [SRT] = []

        var index = 0
        while index < lines.count {
            if
                let id = Int(lines[index]),
                let range = lines[index + 1]
                    .split(separator: " ")
                    .first(where: { $0 == "-->" })
                    .map(String.init)?
                    .surroundingWords,
                range.count == 2
            {
                let content = lines[index + 2]
                let subtitle = SRT(id: id, start: range[0], end: range[1], content: content)
                subtitles.append(subtitle)
                index += 3
            } else {
                index += 1
            }
        }
        return subtitles
    }

    public static func exportSRT(subtitles: [SRT]) -> String {
        return subtitles.map { "\($0.id)\n\($0.start) --> \($0.end)\n\($0.content)" }
            .joined(separator: "\n\n")
    }
}
