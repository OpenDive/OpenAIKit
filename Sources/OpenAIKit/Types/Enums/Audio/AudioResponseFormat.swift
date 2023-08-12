//
//  AudioResponseFormat.swift
//  
//
//  Created by Marcus Arnett on 8/6/23.
//

import Foundation

public enum AudioResponseFormat: String, Codable {
    enum CodingKeys: String, CodingKey {
        case json
        case text
        case srt
        case verboseJson = "verbose_json"
        case vtt
    }
    
    case json
    case text
    case srt
    case verboseJson
    case vtt
}
