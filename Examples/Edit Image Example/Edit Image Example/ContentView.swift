//
//  ContentView.swift
//  Edit Image Example
//
//  Copyright (c) 2022 MarcoDotIO
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

struct ContentView: View {
    @State private var image: UIImage = UIImage()
    
    var body: some View {
        VStack {
            if (image == UIImage()) {
                Text("Loading edit...")
            } else {
                Image(uiImage: image)
            }
        }
        .padding()
        .task {
            do {
                let config = Configuration(organization: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")
                
                let openAI = OpenAI(config)
                
                guard let image = UIImage(named: "image")?.pngData() else { throw OpenAIError.invalidData }
                guard let mask = UIImage(named: "mask")?.pngData() else { throw OpenAIError.invalidData }
                
                let imageEditParam = ImageEditParameters(
                    image: image,
                    imageName: "image.png",
                    mask: mask,
                    maskName: "mask.png",
                    prompt: "A cute baby sea otter wearing a beret",
                    resolution: .small,
                    responseFormat: .base64Json
                )
                
                let imageResponse = try await openAI.generateImageEdits(parameters: imageEditParam)
                
                self.image = UIImage(data: Data(base64Encoded: imageResponse.data[0].image)!)!
            } catch {
                print("ERROR - \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
