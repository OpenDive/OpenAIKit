//
//  RetrieveFileExample.swift
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

struct RetrieveFileExample: View {
    @State private var file: OpenAIFile?
    @State private var isRetrieving: Bool = false
    
    var body: some View {
        if isRetrieving {
            VStack {
                if let file = file {
                    Text("Loading file complete!")
                    Text("ID: \(file.id)")
                    Text("Object: \(file.object)")
                    Text("Size: \(file.bytes.map(String.init) ?? "-") bytes")
                    Text("Created At: \(Date(timeIntervalSince1970: TimeInterval(file.createdAt)).formatted())")
                    Text("Filename: \(file.filename)")
                    Text("Purpose: \(file.purpose.rawValue)")
                    Text("Status: \(file.status.rawValue)")
                } else {
                    Text("Loading file...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isRetrieving = true
                    
                    Task {
                        do {
                            // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                            let openAI = OpenAI(Configuration(apiKey: "INSERT-API-KEY"))

                            self.file = try await openAI.files.retrieve(fileID: "INSERT-FILE-ID")
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Retrieve File")
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

struct RetrieveFileExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RetrieveFileExample()
        }
    }
}
