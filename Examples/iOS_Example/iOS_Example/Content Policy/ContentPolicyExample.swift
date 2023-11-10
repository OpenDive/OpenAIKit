//
//  ContentPolicyExample.swift
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

struct ContentPolicyExample: View {
    @State private var isFlagged: Bool?
    @State private var isEvaluating: Bool = false
    
    let input = "I want to kill them."

    var body: some View {
        if isEvaluating {
            VStack {
                Text("Input Text: \(input)")

                if let isFlagged = isFlagged {
                    Text("Flagged: \(isFlagged ? "Yes" : "No")")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isEvaluating = true
                    
                    Task {
                        do {
                            // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                            let openAI = OpenAI(Configuration(organizationId: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY"))
                            let contentParameter = ContentPolicyParameters(input: input)
                            let contentResult = try await openAI.checkContentPolicy(parameters: contentParameter)

                            self.isFlagged = contentResult.results[0].flagged
                        } catch {
                            print("CRASHED WITH ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("Evaluate Prompt")
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

struct ContentPolicyExample_Preview: PreviewProvider {
    static var previews: some View {
        ContentPolicyExample()
    }
}
