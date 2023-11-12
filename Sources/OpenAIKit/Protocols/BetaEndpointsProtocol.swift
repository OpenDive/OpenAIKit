//
//  BetaEndpointsProtocol.swift
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

public protocol BetaEndpointsProtocol {
    // MARK: Assistant Functions
    /// Create an assistant with a model and instructions.
    func createAssistants(parameters param: AssistantParameters) async throws -> Assistant

    /// Retrieves an assistant.
    func retrieveAssistant(assistantId id: String) async throws -> Assistant

    /// Modifies an assistant.
    func modifyAssistant(assistantId id: String, parameters param: AssistantParameters) async throws -> Assistant

    /// Delete an assistant.
    func deleteAssistant(assistantId id: String) async throws -> DeleteObject

    /// Returns a list of assistants.
    func listAssistants(parameters param: AssistantListParameters) async throws -> AssistantList


    // MARK: Assistant Files Functions
    /// Create an assistant file by attaching a [File](https://platform.openai.com/docs/api-reference/files)
    /// to an [assistant](https://platform.openai.com/docs/api-reference/assistants).
    func createAssistantFile(assistantId: String, fileId: String) async throws -> AssistantFile

    /// Retrieves an AssistantFile.
    func retrieveAssistantFile(assistantId: String, fileId: String) async throws -> AssistantFile

    /// Delete an AssistantFile.
    func deleteAssistantFile(assistantId: String, fileId: String) async throws -> DeleteObject

    /// Returns a list of assistant files.
    func listAssistantFiles(assistantId: String, parameters param: AssistantListParameters) async throws -> AssistantFileList


    // MARK: Thread Functions
    /// Create a thread.
    func createThread(parameters param: ThreadParameters) async throws -> Thread

    /// Retrieves a thread.
    func retrieveThread(threadId id: String) async throws -> Thread

    /// Modifies a thread.
    func modifyThread(threadId id: String, metadata: [String: String]) async throws -> Thread

    /// Delete a thread.
    func deleteThread(threadId id: String) async throws -> DeleteObject
}
