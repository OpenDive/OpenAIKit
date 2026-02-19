//
//  OpenAIError.swift
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

/// OpenAIKit errors that are thrown depending on the context.
public enum OpenAIError: Error {
    /// No API Key was provided to the OpenAIKit object.
    case noApiKey
    
    /// No body was provided to a decode URL request.
    case noBody
    
    /// The amount of prompts being requested have exceeded the amount OpenAI allocates per time frame.
    case promptThreshold
    
    /// An invalid URL was unwrapped / used.
    case invalidUrl
    
    /// Invalid data was decoded / encoded.
    case invalidData
    
    /// The function has not been implemented yet.
    case notImplemented

    /// An incorrect input was found in the ImageParameter. Please edit the input and try submitting again.
    case incompatibleImageParameter(incorrctInput: Any?)

    /// An unknown error has occured. Please create an issue on [Github](https://github.com/OpenDive/OpenAIKit) if this error is thrown.
    case unknownError
}

/// HTTP status-aware API errors mapped from OpenAI responses.
public enum OpenAIAPIError: Error {
    case badRequest(OpenAIErrorResponse?)
    case authentication(OpenAIErrorResponse?)
    case permissionDenied(OpenAIErrorResponse?)
    case notFound(OpenAIErrorResponse?)
    case conflict(OpenAIErrorResponse?)
    case unprocessableEntity(OpenAIErrorResponse?)
    case rateLimit(OpenAIErrorResponse?)
    case internalServer(statusCode: Int, payload: OpenAIErrorResponse?)
    case unexpectedStatusCode(statusCode: Int, payload: OpenAIErrorResponse?)
}
