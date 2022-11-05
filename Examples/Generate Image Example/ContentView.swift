//
//  ContentView.swift
//  Generate Image Example
//
//  Created by Marcus Arnett on 11/4/22.
//

import SwiftUI
import OpenAIKit
import Foundation

struct ContentView: View {
    @State private var image: UIImage = UIImage()
    
    var body: some View {
        VStack {
            Image(uiImage: image)
        }
        .padding()
        .task {
            do {
                let apiKey = "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"
                
                let openAi = OpenAI(key: apiKey)
                
                let imageParam = ImageParameters(prompt: "a red apple", resolution: .small, responseFormat: .base64Json)
                let result = try await openAi.generateImages(parameters: imageParam)
                let b64_image = result.data[0].b64_json!
                
                self.image = UIImage(data: Data(base64Encoded: b64_image)!)!
            } catch {
                print("DEBUG: ERROR DETAILS - \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
