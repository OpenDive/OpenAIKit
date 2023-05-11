//
//  ListModelsExample.swift
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

struct ListModelsExample: View {
    @State private var models = [Model]()
    @State private var isListing: Bool = false

    var body: some View {
        if isListing {
            if !models.isEmpty {
                List(models) { model in
                    Text("\(model.id)")
                }
            } else {
                Text("Loading Models...")
            }
        } else {
            VStack {
                Button {
                    isListing = true
                    
                    Task {
                        do {
                            let config = Configuration(
                                organizationId: "INSERT-ORGANIZATION-ID",
                                apiKey: "INSERT-API-KEY"
                            )
                            let openAi = OpenAIKit(config)
                            let modelsResponse = try await openAi.listModels()

                            self.models = modelsResponse.data
                        } catch {
                            print("ERROR DETAILS - \(error)")
                        }
                    }
                } label: {
                    Text("List Models")
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

struct ListModelsExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListModelsExample()
        }
    }
}
