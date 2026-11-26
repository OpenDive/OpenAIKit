//
//  GenerateImageExample.swift
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

struct GenerateImageExample: View {
    @State private var image: UIImage?
    @State private var isGenerating: Bool = false

    var body: some View {
        if isGenerating {
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Generating image...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isGenerating = true

                    Task {
                        do {
                            // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                            let openAI = OpenAI(Configuration(apiKey: "INSERT-API-KEY"))

                            // GPT Image models always return base64-encoded image data.
                            let result = try await openAI.images.generate(
                                CreateImageRequest(
                                    model: "gpt-image-2",
                                    prompt: "an avocado chair",
                                    quality: .high,
                                    size: ._1024x1536
                                )
                            )

                            if let data = result.data?.first?.imageData {
                                self.image = UIImage(data: data)
                            }
                        } catch {
                            print("ERROR DETAILS - \(error)")
                        }
                    }
                } label: {
                    Text("Generate Image")
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

struct GenerateImageExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GenerateImageExample()
        }
    }
}
