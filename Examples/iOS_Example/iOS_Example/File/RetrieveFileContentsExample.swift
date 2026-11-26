//
//  RetrieveFileContentsExample.swift
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

struct RetrieveFileContentsExample: View {
    @State private var lines: [String]?
    @State private var isRetrieving: Bool = false

    var body: some View {
        if isRetrieving {
            VStack {
                if let lines = self.lines {
                    Text("Retrieved file!")
                    Text("Line count: \(lines.count)")
                    Text("First three lines (see log for the full file): ")
                    ForEach(lines.prefix(3), id: \.self) { line in
                        Text(line)
                            .lineLimit(3)
                    }
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
                            // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                            let openAI = OpenAI(Configuration(apiKey: "INSERT-API-KEY"))

                            // Returns the file's raw bytes. The upload example sends a JSON Lines file.
                            let data = try await openAI.files.retrieveContent(fileID: "INSERT-FILE-ID")
                            let text = String(decoding: data, as: UTF8.self)
                            print(text)

                            self.lines = text
                                .split(whereSeparator: \.isNewline)
                                .map(String.init)
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
