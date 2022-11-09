//
//  MockOpenAI.swift
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

import Foundation
@testable import OpenAIKit

class MockOpenAI: OpenAIProtocol {
    func getDecodedData<T: Decodable>(_ type: T.Type = T.self, with jsonData: String) async throws -> T {
        guard let url = Bundle.test.url(forResource: jsonData, withExtension: "json") else {
            print("Getting Url for bundle has failed.")
            throw MockOpenAIError.urlBundleFailed
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Setting data using contents of url has failed.")
            throw MockOpenAIError.dataCoersionFailed
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        guard let result = try? decoder.decode(T.self, from: data) else {
            print("Decoding data has failed.")
            throw MockOpenAIError.dataCodingFailed
        }

        return result
    }
    
    func listModels() async throws -> ListModelResponse {
        return try await getDecodedData(with: "ModelsResponse") as ListModelResponse
    }
    
    func retrieveModel(modelId id: String) async throws -> Model {
        return try await getDecodedData(with: "RetrieveModelResponse") as Model
    }
    
    func generateCompletion(parameters param: CompletionParameters) async throws -> CompletionResponse {
        return try await getDecodedData(with: "CompletionResponse") as CompletionResponse
    }
    
    func generateEdit(parameters param: EditParameters) async throws -> EditResponse {
        return try await getDecodedData(with: "EditResponse") as EditResponse
    }
    
    func generateImages(parameters param: ImageParameters) async throws -> ImageResponse {
        if let user = param.user {
            switch user {
                case "promptApple": return try await getDecodedData(with: "ImageApple") as ImageResponse
                case "promptOtter": return try await getDecodedData(with: "ImageOtter") as ImageResponse
                case "promptEmpty": throw MockOpenAIError.invalidPrompt
                case "number1": return try await getDecodedData(with: "ImageURL1") as ImageResponse
                case "number2": return try await getDecodedData(with: "ImageURL2") as ImageResponse
                case "number10": return try await getDecodedData(with: "ImageURL10") as ImageResponse
                case "number11": return try await getDecodedData(with: "ImageURL11") as ImageResponse
                case "number0": return try await getDecodedData(with: "ImageURL0") as ImageResponse
                case "number-1": return try await getDecodedData(with: "ImageURL-1") as ImageResponse
                case "sizeSmallURL": return try await getDecodedData(with: "ImageURLSmall") as ImageResponse
                case "sizeSmallB64": return try await getDecodedData(with: "ImageB64Small") as ImageResponse
                case "sizeMediumURL": return try await getDecodedData(with: "ImageURLMedium") as ImageResponse
                case "sizeMediumB64": return try await getDecodedData(with: "ImageB64Medium") as ImageResponse
                case "sizeLargeURL": return try await getDecodedData(with: "ImageURLLarge") as ImageResponse
                case "sizeLargeB64": return try await getDecodedData(with: "ImageB64Large") as ImageResponse
                case "responseURL": return try await getDecodedData(with: "ImageURL") as ImageResponse
                case "responseB64": return try await getDecodedData(with: "ImageB64") as ImageResponse
                default: throw MockOpenAIError.invalidUser
            }
        }
        
        throw MockOpenAIError.invalidUser
    }
    
    func generateImageEdits(parameters param: ImageEditParameters) async throws -> ImageResponse {
        throw MockOpenAIError.notImplemented
    }
    
    func checkContentPolicy(parameters param: ContentPolicyParameters) async throws -> ContentPolicyResponse {
        return try await getDecodedData(with: "ContentPolicyResponse") as ContentPolicyResponse
    }
}
