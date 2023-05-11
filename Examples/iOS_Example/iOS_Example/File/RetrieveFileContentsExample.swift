//
//  RetrieveFileContentsExample.swift
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

struct RetrieveFileContentsExample: View {
    @State private var fineTunes: [FineTuneTraining]?
    @State private var isRetrieving: Bool = false

    var body: some View {
        if isRetrieving {
            VStack {
                if let fineTunes = fineTunes {
                    Text("Retrieved file!")
                    Text("Fine-tunes size: \(fineTunes.count)")
                    Text("First three indexes (see log for full object): ")
                    Text("\(fineTunes[0].prompt) - \(fineTunes[0].completion)")
                    Text("\(fineTunes[1].prompt) - \(fineTunes[1].completion)")
                    Text("\(fineTunes[2].prompt) - \(fineTunes[2].completion)")
                } else {
                    Text("Retrieving file...")
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
                            let openAI = OpenAIKit(config)

                            self.fineTunes = try await openAI.retrieveFileContent(fileId: "INSERT-FILE-ID")
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Retrieve File Contents")
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

struct RetrieveFileContentsExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RetrieveFileContentsExample()
        }
    }
}
