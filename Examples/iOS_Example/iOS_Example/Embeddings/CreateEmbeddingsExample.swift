//
//  CreateEmbeddingsExample.swift
//  OpenAIKit
//
//  Copyright (c) 2023 MarcoDotIO
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
import OpenAIKit

struct CreateEmbeddingsExample: View {
    @State private var embeddingsResponse: EmbeddingsResponse?
    @State private var isCreatingEmbeds: Bool = false
    
    let input: String = "The food was delicious and the waiter..."

    var body: some View {
        if isCreatingEmbeds {
            VStack {
                Text("Input: \(input)")
                if let embeddingsResponse = self.embeddingsResponse {
                    Text("Object Type: \(embeddingsResponse.object.rawValue)")
                        .padding(.bottom)

                    Text("Embeddings Details").bold().font(.title)
                    Text("Object Type: \(embeddingsResponse.data[0].object.rawValue)")
                    Text("First Embedding (See Print For Full Embedding output):")
                        .multilineTextAlignment(.center)
                    Text("\(embeddingsResponse.data[0].embedding[0])")
                    Text("Index: \(embeddingsResponse.data[0].index)")

                    Text("Embeddings Usage").bold().font(.title).padding(.top)
                    Text("Prompt Tokens: \(embeddingsResponse.usage.promptTokens)")
                    Text("Total Tokens: \(embeddingsResponse.usage.totalTokens)")

                } else {
                    Text("Loading Embeddings...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isCreatingEmbeds = true
                    
                    Task {
                        do {
                            let config = Configuration(organization: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")
                            let openAI = OpenAI(config)
                            let embeddingsParam = EmbeddingsParameters(model: "text-similarity-babbage-001", input: input)

                            self.embeddingsResponse = try await openAI.createEmbeddings(parameters: embeddingsParam)

                            print("Embeddings Result: ")
                            self.embeddingsResponse?.data[0].embedding.forEach { embed in
                                print("\(embed)")
                            }
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Create Embeddings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
        }
    }
}

struct CreateEmbeddingsExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateEmbeddingsExample()
        }
    }
}
