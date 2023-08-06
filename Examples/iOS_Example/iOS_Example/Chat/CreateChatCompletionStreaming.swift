//
//  CreateChatCompletionStreaming.swift
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

struct CreateChatCompletionStreamingExample: View {
    @State private var responseText: String = ""
    @State private var isCompleting: Bool = false

    let chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "You are a helpful assistant."),
        ChatMessage(role: .user, content: "Who won the world series in 2020?"),
        ChatMessage(role: .assistant, content: "The Los Angeles Dodgers won the World Series in 2020."),
        ChatMessage(role: .user, content: "Where was it played?")
    ]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(chat) { message in
                    Text("\(message.role.rawValue.capitalized): \(message.content)")
                        .padding(.vertical, 10)
                }
            }
            .padding(20)

            if isCompleting {
                VStack {
                    Text(responseText)
                }
                .padding()
            } else {
                VStack {
                    Button {
                        self.isCompleting = true

                        Task {
                            do {
                                let config = Configuration(
                                    organizationId: "INSERT-ORGANIZATION-ID",
                                    apiKey: "INSERT-API-KEY"
                                )
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(model: .chatGPTTurbo, messages: chat)
                                let stream = try openAI.generateChatCompletionStreaming(
                                    parameters: chatParameters
                                )

                                for try await result in stream {
                                    if let delta = result.choices[0].delta {
                                        if let role = delta.role {
                                            self.responseText += "\(role.rawValue.capitalized): "
                                        } else if let content = delta.content {
                                            self.responseText += content
                                        }
                                    }
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Stream Completion")
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

struct CreateChatCompletionStreamingExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateChatCompletionStreamingExample()
        }
    }
}
