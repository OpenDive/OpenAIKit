//
//  Parameter.swift
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

/// Function parameter used for Chat Completion endpoint.
public struct Parameters: Codable {
    enum CodingKeys: String, CodingKey {
        case type, properties, required
    }

    /// The variable type of the parameter
    public var type: String

    /// Parameters used within the function object call
    public var properties: [String: Property]

    /// The required parameters
    public var required: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        properties = [:]
        let propertiesContainer = try container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .properties)

        for key in propertiesContainer.allKeys {
            let decodedProperty = try propertiesContainer.decode(ParameterDetail.self, forKey: key)
            properties[key.stringValue] = decodedProperty
        }

        required = try container.decodeIfPresent([String].self, forKey: .required)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        var propertiesContainer = container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .properties)

        for (key, value) in properties {
            try propertiesContainer.encode(value, forKey: GenericCodingKeys(key: key))
        }

        try container.encode(required, forKey: .required)
    }

    public init(type: String, properties: [String: Property], required: [String]? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
    }

    internal var body: [String: Any] {
        var result: [String: Any] = [
            "type": self.type,
            "properties": self.properties.body
        ]

        if let required = self.required {
            result["required"] = required
        }

        return result
    }
}
