//
//  ChatMainView.swift
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

struct ChatMainView: View {
    var body: some View {
        List {
            Section("Responses API") {
                NavigationLink(destination: CreateResponseExample()) {
                    Text("Create Response Example")
                }

                NavigationLink(destination: CreateResponseStreamingExample()) {
                    Text("Create Response Streaming Example")
                }

                NavigationLink(destination: CreateChatFunctionCallExample()) {
                    Text("Function Calling Example")
                }
            }

            Section("Chat Completions API") {
                NavigationLink(destination: CreateChatCompletionExample()) {
                    Text("Generate Chat Completion Example")
                }

                NavigationLink(destination: CreateChatCompletionStreamingExample()) {
                    Text("Generate Chat Completion Streaming Example")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Chat")
    }
}

/// A message the chat examples show on screen and send to the API.
struct ExampleMessage: Identifiable {
    enum Role: String {
        case system
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let content: String

    /// The conversation every chat example continues.
    static let worldSeriesConversation: [ExampleMessage] = [
        ExampleMessage(role: .system, content: "You are a helpful assistant."),
        ExampleMessage(role: .user, content: "Who won the world series in 2020?"),
        ExampleMessage(role: .assistant, content: "The Los Angeles Dodgers won the World Series in 2020."),
        ExampleMessage(role: .user, content: "Where was it played?")
    ]

    /// The message as a Responses API input item.
    var inputItem: InputItem {
        switch role {
        case .system: return .system(content)
        case .user: return .user(content)
        case .assistant: return .assistant(content)
        }
    }

    /// The message as a Chat Completions API message.
    var chatCompletionMessage: ChatCompletionRequestMessage {
        switch role {
        case .system: return .system(text: content)
        case .user: return .user(text: content)
        case .assistant: return .assistant(text: content)
        }
    }
}

/// Shows the example conversation.
struct ExampleConversationView: View {
    let messages: [ExampleMessage]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(messages) { message in
                Text("\(message.role.rawValue.capitalized): \(message.content)")
                    .padding(.vertical, 10)
            }
        }
        .padding(20)
    }
}

struct ChatMainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatMainView()
        }
    }
}
