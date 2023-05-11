//
//  ListFinetuneEventsExample.swift
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

struct ListFinetuneEventsExample: View {
    @State private var events: [FineTuneEvent]?
    @State private var isListing: Bool = false
    
    private let fineTuneId = "INSERT-FINE-TUNE-ID"

    var body: some View {
        if isListing {
            VStack {
                if let events {
                    Text("Fetched events with Fine-tune ID: \(fineTuneId)")
                    ScrollView {
                        ForEach(events, id: \.self) { event in
                            VStack {
                                Text("Object: \(event.object.rawValue)")
                                Text("Created At: \(event.createdAt)")
                                Text("Level: \(event.level.rawValue)")
                                Text("Message: \(event.message)")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    Text("Fetching events...")
                }
            }
            .padding()
        } else {
            VStack {
                Button {
                    isListing = true
                    
                    Task {
                        do {
                            let config = Configuration(organizationId: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")
                            let openAI = OpenAIKit(config)
                            let listFineTuneEventResponse = try await openAI.listFineTuneEvents(fineTune: fineTuneId)

                            self.events = listFineTuneEventResponse.data
                        } catch {
                            print("ERROR - \(error)")
                        }
                    }
                } label: {
                    Text("List Fine-tune")
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

struct ListFinetuneEventsExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListFinetuneEventsExample()
        }
    }
}
