// Copyright (c) 2023-2026 OpenDive. Released under the MIT License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// One HTTP request to the OpenAI API, before credentials and defaults are applied.
public struct OpenAIRequest: Sendable {
    public enum Authentication: Sendable {
        /// `Configuration.apiKey`.
        case apiKey
        /// `Configuration.adminAPIKey`, for the Administration API.
        case admin
    }

    public enum Body: Sendable {
        case none
        case json(Data)
        case multipart([MultipartPart])
        case raw(Data, contentType: String)
    }

    public var method: String
    /// Path relative to `Configuration.baseURL`, starting with `/`.
    public var path: String
    public var query: [URLQueryItem] = []
    public var headers: [String: String] = [:]
    public var body: Body = .none
    public var authentication: Authentication = .apiKey

    public init(method: String, path: String) {
        self.method = method
        self.path = path
    }

    /// Percent-encodes one path segment.
    public static func escape(_ segment: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#")
        return segment.addingPercentEncoding(withAllowedCharacters: allowed) ?? segment
    }

    public mutating func addQuery(_ name: String, _ value: String) {
        query.append(URLQueryItem(name: name, value: value))
    }

    /// Adds a query parameter. Arrays become `name[]=a&name[]=b` and objects `name[key]=value`,
    /// the format the OpenAI API expects. `nil` adds nothing.
    public mutating func addQuery<T: Encodable>(_ name: String, _ value: T?) throws {
        guard let value else { return }
        let json = try JSONValue(encoding: value)
        for (key, item) in Self.flatten(json, key: name, arraySuffixUnlessPresent: true) {
            if case .file = item { continue }
            if case .text(let text) = item { query.append(URLQueryItem(name: key, value: text)) }
        }
    }

    public mutating func setJSONBody<T: Encodable>(_ value: T, overrides: [String: JSONValue] = [:]) throws {
        if overrides.isEmpty {
            body = .json(try JSONEncoder.openAI.encode(value))
            return
        }
        guard case .object(var object) = try JSONValue(encoding: value) else {
            body = .json(try JSONEncoder.openAI.encode(value))
            return
        }
        for (key, override) in overrides { object[key] = override }
        body = .json(try JSONEncoder.openAI.encode(JSONValue.object(object)))
    }

    public mutating func setMultipartBody<T: Encodable>(_ value: T, overrides: [String: JSONValue] = [:]) throws {
        let collector = MultipartCollector()
        let encoder = JSONEncoder.openAI
        encoder.userInfo[MultipartCollector.key] = collector
        var json = try JSONDecoder().decode(JSONValue.self, from: encoder.encode(value))
        if case .object(var object) = json {
            for (key, override) in overrides { object[key] = override }
            json = .object(object)
        }
        var parts: [MultipartPart] = []
        let keys = json.objectValue.map { $0.keys.sorted() } ?? []
        for key in keys {
            guard let field = json[key] else { continue }
            for (name, item) in Self.flatten(field, key: key, arraySuffixUnlessPresent: true) {
                switch item {
                case .text(let text):
                    if text.hasPrefix(collector.marker), let file = collector.files[text] {
                        parts.append(.file(name: name, file: file))
                    } else {
                        parts.append(.text(name: name, value: text))
                    }
                case .file(let file):
                    parts.append(.file(name: name, file: file))
                }
            }
        }
        body = .multipart(parts)
    }

    public mutating func setRawBody(_ data: Data, contentType: String) {
        body = .raw(data, contentType: contentType)
    }

    enum FlatValue {
        case text(String)
        case file(FileUpload)
    }

    static func flatten(_ value: JSONValue, key: String, arraySuffixUnlessPresent: Bool) -> [(String, FlatValue)] {
        switch value {
        case .null:
            return []
        case .bool(let bool):
            return [(key, .text(bool ? "true" : "false"))]
        case .integer(let int):
            return [(key, .text(String(int)))]
        case .number(let number):
            return [(key, .text(number.rounded() == number && abs(number) < 1e15 ? String(Int(number)) : String(number)))]
        case .string(let string):
            return [(key, .text(string))]
        case .array(let items):
            let arrayKey = key.hasSuffix("[]") ? key : key + "[]"
            return items.flatMap { flatten($0, key: arrayKey, arraySuffixUnlessPresent: arraySuffixUnlessPresent) }
        case .object(let object):
            return object.keys.sorted().flatMap { child in
                flatten(object[child]!, key: "\(key)[\(child)]", arraySuffixUnlessPresent: arraySuffixUnlessPresent)
            }
        }
    }
}

/// One part of a `multipart/form-data` body.
public enum MultipartPart: Sendable, Hashable {
    case text(name: String, value: String)
    case file(name: String, file: FileUpload)

    static func encode(_ parts: [MultipartPart], boundary: String) -> Data {
        var data = Data()
        func append(_ string: String) { data.append(Data(string.utf8)) }
        for part in parts {
            append("--\(boundary)\r\n")
            switch part {
            case .text(let name, let value):
                append("Content-Disposition: form-data; name=\"\(escapeQuotes(name))\"\r\n\r\n")
                append(value)
            case .file(let name, let file):
                append("Content-Disposition: form-data; name=\"\(escapeQuotes(name))\"; filename=\"\(escapeQuotes(file.filename))\"\r\n")
                append("Content-Type: \(file.resolvedContentType)\r\n\r\n")
                data.append(file.data)
            }
            append("\r\n")
        }
        append("--\(boundary)--\r\n")
        return data
    }

    private static func escapeQuotes(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
    }
}
