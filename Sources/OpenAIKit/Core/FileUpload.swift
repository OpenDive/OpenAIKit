// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation

/// A file sent in a `multipart/form-data` request, such as an audio file to transcribe or an image to edit.
public struct FileUpload: Codable, Hashable, Sendable {
    /// The file's bytes.
    public var data: Data
    /// The file name sent to the server. OpenAI uses its extension to detect the format.
    public var filename: String
    /// The part's `Content-Type`. When `nil`, OpenAIKit derives it from the file name.
    public var contentType: String?

    public init(data: Data, filename: String, contentType: String? = nil) {
        self.data = data
        self.filename = filename
        self.contentType = contentType
    }

    /// Reads a file from disk.
    public init(contentsOf url: URL, filename: String? = nil, contentType: String? = nil) throws {
        self.data = try Data(contentsOf: url)
        self.filename = filename ?? url.lastPathComponent
        self.contentType = contentType
    }

    /// The content type sent for this part.
    public var resolvedContentType: String {
        if let contentType { return contentType }
        let ext = filename.split(separator: ".").count > 1 ? String(filename.split(separator: ".").last!).lowercased() : ""
        return FileUpload.contentTypes[ext] ?? "application/octet-stream"
    }

    static let contentTypes: [String: String] = [
        "aac": "audio/aac", "flac": "audio/flac", "m4a": "audio/mp4", "mp3": "audio/mpeg",
        "mp4": "video/mp4", "mpeg": "audio/mpeg", "mpga": "audio/mpeg", "ogg": "audio/ogg",
        "opus": "audio/opus", "wav": "audio/wav", "webm": "audio/webm", "pcm": "audio/pcm",
        "png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg", "gif": "image/gif",
        "webp": "image/webp", "heic": "image/heic", "pdf": "application/pdf",
        "json": "application/json", "jsonl": "application/jsonl", "txt": "text/plain",
        "md": "text/markdown", "csv": "text/csv", "html": "text/html", "zip": "application/zip",
        "mov": "video/quicktime",
    ]

    private enum CodingKeys: String, CodingKey {
        case data, filename, contentType = "content_type"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base64 = try container.decode(String.self, forKey: .data)
        guard let data = Data(base64Encoded: base64) else {
            throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Expected base64 data")
        }
        self.data = data
        self.filename = try container.decode(String.self, forKey: .filename)
        self.contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
    }

    public func encode(to encoder: any Encoder) throws {
        if let collector = encoder.userInfo[MultipartCollector.key] as? MultipartCollector {
            var container = encoder.singleValueContainer()
            try container.encode(collector.register(self))
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data.base64EncodedString(), forKey: .data)
        try container.encode(filename, forKey: .filename)
        try container.encodeIfPresent(contentType, forKey: .contentType)
    }
}

/// Collects files while a multipart body is encoded, replacing each with a placeholder string.
final class MultipartCollector: @unchecked Sendable {
    static let key = CodingUserInfoKey(rawValue: "OpenAIKit.MultipartCollector")!
    private(set) var files: [String: FileUpload] = [:]
    let marker = "\u{1}openaikit-file:" + UUID().uuidString + ":"

    func register(_ file: FileUpload) -> String {
        let token = marker + String(files.count)
        files[token] = file
        return token
    }
}
