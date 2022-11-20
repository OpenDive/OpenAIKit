//
//  ContentPolicyCategories.swift
//  OpenAIKit
//
//  Copyright (c) 2022 MarcoDotIO
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

/// The categories flagged by the Moderations endpoint.
public struct ContentPolicyCategories: Codable {
    enum CodingKeys: String, CodingKey {
        case hate
        case hateWithThreatening = "hate/threatening"
        case selfHarm = "self-harm"
        case sexual
        case sexualWithMinors = "sexual/minors"
        case violence
        case violenceWithGraphic = "violence/graphic"
    }

    /// Content that expresses, incites, or promotes hate based on race, gender, ethnicity, religion,
    /// nationality, sexual orientation, disability status, or caste.
    public let hate: Bool

    /// Hateful content that also includes violence or serious harm towards the targeted group.
    public let hateWithThreatening: Bool

    /// Content that promotes, encourages, or depicts acts of self-harm, such as suicide,
    /// cutting, and eating disorders.
    public let selfHarm: Bool

    /// Content meant to arouse sexual excitement, such as the description of sexual activity,
    /// or that promotes sexual services (excluding sex education and wellness).
    public let sexual: Bool

    /// Sexual content that includes an individual who is under 18 years old.
    public let sexualWithMinors: Bool

    /// Content that promotes or glorifies violence or celebrates the suffering or
    /// humiliation of others.
    public let violence: Bool

    /// Violent content that depicts death, violence, or serious physical injury in
    /// extreme graphic detail.
    public let violenceWithGraphic: Bool
}
