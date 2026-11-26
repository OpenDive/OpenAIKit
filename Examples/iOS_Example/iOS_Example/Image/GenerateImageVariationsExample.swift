//
//  GenerateImageVariationExample.swift
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

/// Image variations are only available with `dall-e-2`. OpenAI marks this endpoint as deprecated
/// (it still works); the edit example shows the GPT Image alternative.
struct GenerateImageVariationExample: View {
    @State private var image: UIImage?
    @State private var isGeneratingVariation: Bool = false

    var body: some View {
        if isGeneratingVariation {
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Variation is loading...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isGeneratingVariation = true
                    
                    Task {
                        do {
                            let openAI = ExampleSecrets.client

                            guard let imageData = UIImage(named: "variation")?.pngData() else {
                                print("ERROR - variation.png is missing from the app bundle")
                                return
                            }

                            let variationResponse = try await openAI.images.createVariation(
                                CreateImageVariationRequest(
                                    image: FileUpload(data: imageData, filename: "variation.png"),
                                    model: .dallE2,
                                    responseFormat: .b64Json,
                                    size: ._256x256
                                )
                            )

                            if let data = variationResponse.data?.first?.imageData {
                                self.image = UIImage(data: data)
                            }
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Generate Variations")
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

struct GenerateImageVariationExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GenerateImageVariationExample()
        }
    }
}
