//
//  File.swift
//  
//
//  Created by Marcus Arnett on 8/12/23.
//

import Foundation

extension String {
    internal var surroundingWords: [String] {
        let words = self.split(separator: " ")
        guard let index = words.firstIndex(where: { String($0) == self }) else { return [] }
        var surrounding: [String] = []
        if index > 0 { surrounding.append(String(words[index - 1])) }
        if index < words.count - 1 { surrounding.append(String(words[index + 1])) }
        return surrounding
    }

    public var subtitleDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss,SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
