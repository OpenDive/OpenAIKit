//
//  ContentPolicyModels.swift
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

/// Two content moderations models are available: `text-moderation-stable` and `text-moderation-latest`.
/// The default is `text-moderation-latest` which will be automatically upgraded over time.
/// This ensures you are always using our most accurate model.
/// If you use `text-moderation-stable`, we will provide advanced notice before updating the model.
/// Accuracy of `text-moderation-stable` may be slightly lower than for `text-moderation-latest`.
public enum ContentPolicyModels: String, Codable {
    /// The latest model that gets automatically upgraded over time.
    case latest = "text-moderation-latest"
    
    /// The stable model that gets prior notification before being upgraded.
    case stable = "text-moderation-stable"
}
