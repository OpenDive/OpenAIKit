//
//  CreateTranscription.swift
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
import AVFoundation

enum TranscriptionType: String, CaseIterable, Identifiable {
    case english
    case dutch

    var id: Self { self }
}

struct CreateTranscriptionExample: View {
    @StateObject private var viewModel = AudioPlayerViewModel()

    @State private var isCompleting: Bool = false
    @State private var transcription: String = ""
    @State private var selectedLanguage: TranscriptionType = .english

    var audioData: Data? {
        switch selectedLanguage {
        case .english:
            return self.retrieveAudio(type: .english)
        case .dutch:
            return self.retrieveAudio(type: .dutch)
        }
    }

    // English Audio Source: https://librivox.org/12-creepy-tales-by-edgar-allan-poe/
    // 12 - THE PIT AND THE PENDULUM -- Narrator: Eden Rea-Hedrick
    // ---------------------------------------------------------------------------------------
    // Dutch Audio Source: https://librivox.org/the-raven-multilingual-by-edgar-allan-poe/
    // 04 - Dutch: De Raaf (John F. Malta) -- Narrator: Julie VW
    private func retrieveAudio(type: TranscriptionType) -> Data? {
        guard
            let filePath = Bundle.main.path(
                forResource: type == .english ? "audio" : "audio_translation",
                ofType: "mp3"
            ),
            let audio = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        else {
            return nil
        }

        return audio
    }

    var body: some View {
        VStack {
            Picker("Transcription Type", selection: $selectedLanguage) {
                Text("Regular Transcription").tag(TranscriptionType.english)
                Text("Translation Transcription").tag(TranscriptionType.dutch)
            }
            .padding(.bottom, 90)

            Button {
                self.viewModel.play(audioData: self.audioData)
            } label: {
                Text("Play Audio")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }

            if isCompleting {
                VStack {
                    Text(transcription)
                }
                .padding()
            } else {
                VStack {
                    Button {
                        isCompleting = true

                        Task {
                            do {
                                let config = Configuration(
                                    organizationId: "INSERT-ORGANIZATION-ID",
                                    apiKey: "INSERT-API-KEY"
                                )
                                let openAI = OpenAI(config)

                                guard let audio = self.audioData else { throw OpenAIError.invalidData }

                                let audioParameters = TranscriptionParameters(file: audio)
                                let transcriptionCompletion = try await self.selectedLanguage == .english ?
                                    openAI.createTranscription(parameters: audioParameters) :
                                    openAI.createTranslation(parameters: audioParameters)

                                if let text = transcriptionCompletion.text {
                                    self.transcription = text
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Transcription")
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
}

#Preview {
    CreateTranscriptionExample()
}
