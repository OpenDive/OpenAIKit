//
//  EditImageExample.swift
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

struct EditImageExample: View {
    @State private var image: UIImage?
    @State private var isEditing: Bool = false

    var body: some View {
        if isEditing {
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Loading edit...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isEditing = true

                    Task {
                        do {
                            // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                            let openAI = OpenAI(Configuration(apiKey: "INSERT-API-KEY"))

                            // Re-encode the bundled images: Xcode optimizes PNGs it copies into an iOS
                            // app bundle into a format other decoders cannot read. The mask's transparent
                            // pixels mark the area to edit; it must be the same size as the image.
                            guard
                                let imageData = UIImage(named: "image")?.pngData(),
                                let maskData = UIImage(named: "mask")?.pngData()
                            else {
                                print("ERROR - image.png or mask.png is missing from the app bundle")
                                return
                            }

                            let imageResponse = try await openAI.images.edit(
                                CreateImageEditRequest(
                                    model: "gpt-image-2",
                                    prompt: "A cute baby sea otter wearing a beret",
                                    image: .file(FileUpload(data: imageData, filename: "image.png")),
                                    mask: FileUpload(data: maskData, filename: "mask.png"),
                                    size: ._1024x1024
                                )
                            )

                            if let data = imageResponse.data?.first?.imageData {
                                self.image = UIImage(data: data)
                            }
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Edit Image")
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

struct EditImageExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditImageExample()
        }
    }
}
