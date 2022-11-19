//
//  OpenAIProtocol.swift
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

public protocol OpenAIProtocol {
    func listModels() async throws -> ListModelResponse
    
    func retrieveModel(modelId id: String) async throws -> Model
    
    func generateCompletion(parameters param: CompletionParameters) async throws -> CompletionResponse
    
    func generateEdit(parameters param: EditParameters) async throws -> EditResponse
    
    func createImage(parameters param: ImageParameters) async throws -> ImageResponse
    
    func generateImageEdits(parameters param: ImageEditParameters) async throws -> ImageResponse
    
    func generateImageVariations(parameters param: ImageVariationParameters) async throws -> ImageResponse
    
    func createEmbeddings(parameters param: EmbeddingsParameters) async throws -> EmbeddingsResponse
    
    func listFiles() async throws -> ListFilesResponse
    
    func uploadFile(parameters param: UploadFileParameters) async throws -> File
    
    func deleteFile(fileId id: String) async throws -> DeleteObject
    
    func retrieveFile(fileId id: String) async throws -> File
    
    func retrieveFileContent(fileId id: String) async throws -> [FineTuneTraining]
    
    func createFineTune(parameters param: CreateFineTuneParameters) async throws -> FineTune
    
    func listFineTunes() async throws -> ListFineTuneResponse
    
    func retrieveFineTune(fineTune id: String) async throws -> FineTune
    
    func cancelFineTune(fineTune id: String) async throws -> FineTune
    
    func listFineTuneEvents(fineTune id: String) async throws -> FineTuneEventsResponse
    
    func deleteFineTuneModel(model: String) async throws -> DeleteObject
    
    func checkContentPolicy(parameters param: ContentPolicyParameters) async throws -> ContentPolicyResponse
}
