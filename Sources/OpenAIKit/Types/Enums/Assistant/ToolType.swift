//
//  ToolType.swift
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

/// Give Assistants access to OpenAI-hosted tools like Code Interpreter and Knowledge Retrieval, or build your own tools using Function calling.
public enum ToolType: String, Codable {
    enum CodingKeys: String, CodingKey {
        case codeInterpreter = "code_interpreter"
        case retrieval
        case function
    }

    /// Code Interpreter allows the Assistants API to write and run Python code in a sandboxed execution environment.
    ///
    /// This tool can process files with diverse data and formatting, and generate files with data and images of graphs.
    /// Code Interpreter allows your Assistant to run code iteratively to solve challenging code and math problems.
    /// When your Assistant writes code that fails to run, it can iterate on this code by attempting to run different code until the code execution succeeds.
    case codeInterpreter

    /// Retrieval augments the Assistant with knowledge from outside its model, such as proprietary product information or documents provided by your users.
    ///
    /// Once a file is uploaded and passed to the Assistant, OpenAI will automatically chunk your documents, index and store the embeddings, and implement vector search to retrieve relevant content to answer user queries.
    case retrieval

    /// Similar to the Chat Completions API, the Assistants API supports function calling. Function calling allows you to describe functions to the Assistants and have it intelligently return the functions that need to be called along with their arguments.
    ///
    /// The Assistants API will pause execution during a Run when it invokes functions, and you can supply the results of the function call back to continue the Run execution.
    case function
}
