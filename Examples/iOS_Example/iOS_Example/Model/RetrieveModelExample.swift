//
//  RetrieveModelExample.swift
//  OpenAIKit
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

struct RetrieveModelExample: View {
    @State private var model: Model?
    @State private var isRetrieving: Bool = false
    
    var body: some View {
        if isRetrieving {
            VStack {
                if let model = model {
                    Text("Model Details").bold().font(.title)
                    Text("Name: \(model.id)")
                    Text("Object: \(model.object.rawValue)")
                    Text("Owned By: \(model.ownedBy)")
                    Text("Root: \(model.root)")
                    Text("Parent: \(model.parent ?? "No Parent")").padding(.bottom)

                    VStack {
                        Text("Model Permissions").bold().font(.title)
                        Text("ID: \(model.permission[0].id)")
                        Text("Object: \(model.permission[0].object.rawValue)")
                        Text("Created: \(String(model.permission[0].created))")
                        Text("Allow Create Engine: \(String(model.permission[0].allowCreateEngine))")
                        Text("Allow Sampling: \(String(model.permission[0].allowSampling))")
                        Text("Allow Search Indices: \(String(model.permission[0].allowSearchIndices))")
                        Text("Allow View: \(String(model.permission[0].allowView))")
                        Text("Allow Fine-tuning: \(String(model.permission[0].allowFineTuning))")
                        VStack {
                            Text("Organization: \(model.permission[0].organization)")
                            Text("Group: \(model.permission[0].group ?? "No Group")")
                            Text("Is Blocking: \(String(model.permission[0].isBlocking))")
                        }
                    }
                } else {
                    Text("Loading Model...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isRetrieving = true
                    
                    Task {
                        do {
                            let config = Configuration(organizationId: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")
                            let openAI = OpenAI(config)

                            self.model = try await openAI.retrieveModel(modelId: "text-davinci-001")
                        } catch {
                            print("ERROR WITH - \(error)")
                        }
                    }
                } label: {
                    Text("Retrieve Model")
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

struct RetrieveModelExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RetrieveModelExample()
        }
    }
}
