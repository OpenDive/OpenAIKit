//
//  OpenAI.swift
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

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// OpenAI provides the needed core functions of OpenAIKit.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class OpenAI {
    /// The configuration object used to store the API Key and Organization ID.
    private var config: Configuration

    public init(_ config: Configuration) {
        self.config = config
    }

    #if os(iOS) || os(tvOS)
    /// Input a `Base64` image binary `String` to receive an `UIImage` object.
    /// - Parameter b64Data: The `Base64` data itself in `String` form.
    /// - Returns: A `UIImage` object.
    public func decodeBase64Image(_ b64Data: String) throws -> UIImage {
        do {
            guard let data = Data(base64Encoded: b64Data) else {
                throw OpenAIError.invalidData
            }

            guard let image = UIImage(data: data) else {
                throw OpenAIError.invalidData
            }

            return image
        } catch {
            throw OpenAIError.invalidData
        }
    }
    #endif

    #if os(macOS)
    /// Input a `Base64` image binary `String` to receive an `NSImage` object.
    /// - Parameter b64Data: The `Base64` data itself in `String` form.
    /// - Returns: A `UIImage` object.
    public func decodeBase64Image(_ b64Data: String) throws -> NSImage {
        do {
            guard let data = Data(base64Encoded: b64Data) else {
                throw OpenAIError.invalidData
            }

            guard let image = NSImage(data: data) else {
                throw OpenAIError.invalidData
            }

            return image
        } catch {
            throw OpenAIError.invalidData
        }
    }
    #endif

    /// Return a `URL` with the OpenAI API endpoint as the `URL`
    /// - Parameter path: The `String` path.
    /// - Returns: An `URL` object.
    private func getServerUrl(path: String) async throws -> URL {
        guard let result = URL(string: "https://api.openai.com/v1\(path)") else {
            throw OpenAIError.invalidUrl
        }

        return result
    }
}

extension OpenAI: OpenAIProtocol {
    public func listModels() async throws -> ListModelResponse {
        let serverUrl = try await getServerUrl(path: "/models")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func retrieveModel(modelId id: String) async throws -> Model {
        let serverUrl = try await getServerUrl(path: "/models/\(id)")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func generateCompletion(parameters param: CompletionParameters) async throws -> CompletionResponse {
        let serverUrl = try await getServerUrl(path: "/completions")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func generateEdit(parameters param: EditParameters) async throws -> EditResponse {
        let serverUrl = try await getServerUrl(path: "/edits")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func createImage(parameters param: ImageParameters) async throws -> ImageResponse {
        let serverUrl = try await getServerUrl(path: "/images/generations")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func generateImageEdits(parameters param: ImageEditParameters) async throws -> ImageResponse {
        let serverUrl = try await getServerUrl(path: "/images/edits")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body,
            formSubmission: true
        )
    }

    public func generateImageVariations(parameters param: ImageVariationParameters) async throws -> ImageResponse {
        let serverUrl = try await getServerUrl(path: "/images/variations")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body,
            formSubmission: true
        )
    }

    public func createEmbeddings(parameters param: EmbeddingsParameters) async throws -> EmbeddingsResponse {
        let serverUrl = try await getServerUrl(path: "/embeddings")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func listFiles() async throws -> ListFilesResponse {
        let serverUrl = try await getServerUrl(path: "/files")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func uploadFile(parameters param: UploadFileParameters) async throws -> File {
        let serverUrl = try await getServerUrl(path: "/files")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body,
            formSubmission: true
        )
    }

    public func deleteFile(fileId id: String) async throws -> DeleteObject {
        let serverUrl = try await getServerUrl(path: "/files/\(id)")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .delete,
            bodyRequired: false
        )
    }

    public func retrieveFile(fileId id: String) async throws -> File {
        let serverUrl = try await getServerUrl(path: "/files/\(id)")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func retrieveFileContent(fileId id: String) async throws -> [FineTuneTraining] {
        let serverUrl = try await getServerUrl(path: "/files/\(id)/content")
        return try await URLSession.shared.retrieveJsonLine(
            with: serverUrl,
            apiKey: config.apiKey
        )
    }

    public func createFineTune(parameters param: CreateFineTuneParameters) async throws -> FineTune {
        let serverUrl = try await getServerUrl(path: "/fine-tunes")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }

    public func listFineTunes() async throws -> ListFineTuneResponse {
        let serverUrl = try await getServerUrl(path: "/fine-tunes")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func retrieveFineTune(fineTune id: String) async throws -> FineTune {
        let serverUrl = try await getServerUrl(path: "/fine-tunes/\(id)")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func cancelFineTune(fineTune id: String) async throws -> FineTune {
        let serverUrl = try await getServerUrl(path: "/fine-tunes/\(id)/cancel")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .post,
            bodyRequired: false
        )
    }

    public func listFineTuneEvents(fineTune id: String) async throws -> FineTuneEventsResponse {
        let serverUrl = try await getServerUrl(path: "/fine-tunes/\(id)/events")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .get,
            bodyRequired: false
        )
    }

    public func deleteFineTuneModel(model: String) async throws -> DeleteObject {
        let serverUrl = try await getServerUrl(path: "/models/\(model)")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            method: .delete,
            bodyRequired: false
        )
    }

    public func checkContentPolicy(
        parameters param: OpenAIKit.ContentPolicyParameters
    ) async throws -> ContentPolicyResponse {
        let serverUrl = try await getServerUrl(path: "/moderations")
        return try await URLSession.shared.decodeUrl(
            with: serverUrl,
            apiKey: config.apiKey,
            body: param.body
        )
    }
}
