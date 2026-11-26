//
//  CreateChatCompletion.swift
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

import SwiftUI
import OpenAIKit

/// The Chat Completions API. The Responses API examples show the newer way to do the same.
struct CreateChatCompletionExample: View {
    @State private var responseText: String?
    @State private var isCompleting: Bool = false

    let chat = ExampleMessage.worldSeriesConversation

    var body: some View {
        VStack {
            ExampleConversationView(messages: chat)

            if isCompleting {
                VStack {
                    if let responseText = self.responseText {
                        Text("Assistant: \(responseText)")
                    } else {
                        Text("Assistant: ...")
                    }
                }
                .padding()
            } else {
                VStack {
                    Button {
                        isCompleting = true

                        Task {
                            do {
                                let openAI = ExampleSecrets.client
                                let chatCompletion = try await openAI.chat.completions.create(
                                    CreateChatCompletionRequest(
                                        model: "gpt-6.2-astra",
                                        messages: chat.map(\.chatCompletionMessage)
                                    )
                                )

                                self.responseText = chatCompletion.firstContent
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Completion")
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

        Spacer()
    }
}

struct CreateChatCompletionExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateChatCompletionExample()
        }
    }
}
