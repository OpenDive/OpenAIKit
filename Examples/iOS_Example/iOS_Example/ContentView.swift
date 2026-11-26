//
//  ContentView.swift
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

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ShowcaseChatView()) {
                        ShowcaseCard(title: "Chat", subtitle: "Streaming with the Responses API", symbol: "bubble.left.and.text.bubble.right.fill", gradient: ShowcaseStyle.chat)
                    }
                    NavigationLink(destination: ShowcaseImageView()) {
                        ShowcaseCard(title: "Image Studio", subtitle: "Generate images with gpt-image-2", symbol: "wand.and.stars", gradient: ShowcaseStyle.image)
                    }
                    NavigationLink(destination: ShowcaseRealtimeView()) {
                        ShowcaseCard(title: "Realtime", subtitle: "Live events over a WebSocket", symbol: "waveform", gradient: ShowcaseStyle.realtime)
                    }
                } header: {
                    Text("Showcase")
                }

                Section("API examples") {
                    NavigationLink("Chat & Responses", destination: ChatMainView())
                    NavigationLink("Images", destination: ImageMainView())
                    NavigationLink("Audio", destination: CreateTranscriptionExample())
                    NavigationLink("Embeddings", destination: CreateEmbeddingsExample())
                    NavigationLink("Files", destination: FileMainView())
                    NavigationLink("Models", destination: ModelMainView())
                    NavigationLink("Moderation", destination: ContentPolicyExample())
                    NavigationLink("Completions (legacy)", destination: CompletionMainView())
                }
            }
            .navigationTitle("OpenAIKit")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
