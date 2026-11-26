//
//  Showcase.swift
//  iOS_Example
//
//  Copyright (c) 2023-2026 OpenDive. Released under the MIT License.
//

import SwiftUI
import OpenAIKit

/// Where the examples get their API key.
///
/// Set `OPENAI_API_KEY` in Product › Scheme › Edit Scheme… › Run › Arguments › Environment Variables,
/// or launch from the command line with `SIMCTL_CHILD_OPENAI_API_KEY=sk-... xcrun simctl launch booted <bundle id>`.
/// ⚠️🔑 Never ship an API key inside an app. Call OpenAI through your own backend in production. 🔑⚠️
enum ExampleSecrets {
    static var apiKey: String {
        ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "INSERT-API-KEY"
    }

    static var client: OpenAI {
        OpenAI(Configuration(apiKey: apiKey))
    }
}

// MARK: - Shared styling

enum ShowcaseStyle {
    static let chat = LinearGradient(colors: [Color(red: 0.36, green: 0.42, blue: 1.0), Color(red: 0.64, green: 0.33, blue: 0.98)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let image = LinearGradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.36), Color(red: 1.0, green: 0.27, blue: 0.62)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let realtime = LinearGradient(colors: [Color(red: 0.1, green: 0.78, blue: 0.62), Color(red: 0.11, green: 0.55, blue: 0.95)], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct SuggestionChips: View {
    let suggestions: [String]
    let action: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        action(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ShowcaseCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Chat (Responses API, streaming)

struct ShowcaseChatView: View {
    struct Message: Identifiable {
        let id = UUID()
        let isUser: Bool
        var text: String
    }

    @State private var messages: [Message] = []
    @State private var draft = ""
    @State private var isStreaming = false
    @State private var previousResponseID: String?
    @State private var errorText: String?

    private let suggestions = [
        "Write a haiku about Swift concurrency",
        "Explain actors like I'm five",
        "Three app ideas using the Realtime API",
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if messages.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 44))
                                    .foregroundStyle(ShowcaseStyle.chat)
                                Text("Ask anything").font(.title2.bold())
                                Text("Streams token by token from the Responses API.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 80)
                        }
                        ForEach(messages) { message in
                            bubble(message).id(message.id)
                        }
                        if let errorText {
                            Text(errorText).font(.footnote).foregroundStyle(.red).padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.last?.text) { _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }

            VStack(spacing: 10) {
                if messages.isEmpty {
                    SuggestionChips(suggestions: suggestions) { send($0) }
                }
                HStack(spacing: 10) {
                    TextField("Message", text: $draft, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    Button {
                        send(draft)
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(ShowcaseStyle.chat, in: Circle())
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || isStreaming)
                    .opacity(draft.trimmingCharacters(in: .whitespaces).isEmpty || isStreaming ? 0.4 : 1)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .background(.bar)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bubble(_ message: Message) -> some View {
        HStack {
            if message.isUser { Spacer(minLength: 48) }
            Text(message.text.isEmpty ? "…" : message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(message.isUser ? .white : .primary)
                .background {
                    if message.isUser {
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(ShowcaseStyle.chat)
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemBackground))
                    }
                }
            if !message.isUser { Spacer(minLength: 48) }
        }
    }

    private func send(_ text: String) {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isStreaming else { return }
        draft = ""
        errorText = nil
        messages.append(Message(isUser: true, text: prompt))
        messages.append(Message(isUser: false, text: ""))
        isStreaming = true

        Task {
            defer { isStreaming = false }
            do {
                let request = CreateResponse(
                    model: "gpt-6.2-astra",
                    input: .inputItemList([.user(prompt)]),
                    instructions: "Be concise and friendly.",
                    previousResponseID: previousResponseID
                )
                for try await event in ExampleSecrets.client.responses.createStream(request) {
                    if let delta = event.outputTextDelta {
                        messages[messages.count - 1].text += delta
                    } else if let response = event.completedResponse {
                        previousResponseID = response.id
                    }
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - Image studio (Images API, streaming)

struct ShowcaseImageView: View {
    @State private var prompt = "A watercolor otter reading a book"
    @State private var image: UIImage?
    @State private var isGenerating = false
    @State private var startedAt = Date()
    @State private var errorText: String?

    private let styles = ["Watercolor", "3D render", "Isometric pixel art", "Studio photo"]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else if isGenerating {
                        TimelineView(.periodic(from: startedAt, by: 0.1)) { context in
                            let elapsed = context.date.timeIntervalSince(startedAt)
                            ZStack {
                                AngularGradient(colors: [.orange, .pink, .purple, .blue, .orange], center: .center, angle: .degrees(elapsed * 90))
                                    .blur(radius: 60)
                                    .opacity(0.55)
                                VStack(spacing: 8) {
                                    ProgressView().controlSize(.large).tint(.white)
                                    Text("Painting… \(Int(elapsed))s")
                                        .font(.headline.monospacedDigit())
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 48))
                                .foregroundStyle(ShowcaseStyle.image)
                            Text("Your image appears here").foregroundStyle(.secondary)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(image == nil ? 0 : 0.2), radius: 18, y: 10)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Prompt").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    TextField("Describe an image", text: $prompt, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal)

                SuggestionChips(suggestions: styles) { style in
                    prompt = prompt.components(separatedBy: ", in the style of").first ?? prompt
                    prompt += ", in the style of \(style.lowercased())"
                }

                Button(action: generate) {
                    Label(isGenerating ? "Generating…" : "Generate", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(ShowcaseStyle.image, in: Capsule())
                }
                .disabled(isGenerating)
                .padding(.horizontal)

                if let errorText {
                    Text(errorText).font(.footnote).foregroundStyle(.red).padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Image Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generate() {
        withAnimation { image = nil }
        errorText = nil
        startedAt = Date()
        isGenerating = true
        Task {
            defer { isGenerating = false }
            do {
                let request = CreateImageRequest(model: "gpt-image-2", prompt: prompt, quality: "medium", partialImages: 2, size: "1024x1024")
                for try await event in ExampleSecrets.client.images.generateStream(request) {
                    switch event {
                    case .imageGenerationPartialImage(let partial):
                        if let data = Data(base64Encoded: partial.b64JSON), let preview = UIImage(data: data) {
                            withAnimation(.easeInOut(duration: 0.4)) { image = preview }
                        }
                    case .imageGenerationCompleted(let completed):
                        if let data = Data(base64Encoded: completed.b64JSON), let final = UIImage(data: data) {
                            withAnimation(.spring(duration: 0.6)) { image = final }
                        }
                    case .unknown:
                        break
                    }
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - Realtime console (Realtime API over WebSocket)

@MainActor
final class RealtimeConsoleModel: ObservableObject {
    enum Status: String { case offline = "Offline", connecting = "Connecting…", live = "Live" }

    @Published var status: Status = .offline
    @Published var transcript: [(id: Int, prompt: String, reply: String)] = []
    @Published var events: [(id: Int, type: String)] = []
    @Published var eventCount = 0
    @Published var errorText: String?

    private var connection: RealtimeConnection?
    private var listener: Task<Void, Never>?
    private var nextID = 0

    func connect() {
        guard status == .offline else { return }
        status = .connecting
        errorText = nil
        do {
            let connection = try ExampleSecrets.client.realtime.connect(model: "gpt-realtime-2")
            self.connection = connection
            listener = Task { await listen(to: connection) }
            Task {
                try? await connection.send(json: [
                    "type": "session.update",
                    "session": ["type": "realtime", "output_modalities": ["text"], "instructions": "Be brief and upbeat."],
                ])
            }
        } catch {
            status = .offline
            errorText = error.localizedDescription
        }
    }

    func disconnect() {
        listener?.cancel()
        connection?.close()
        connection = nil
        status = .offline
    }

    func ask(_ prompt: String) {
        guard let connection, status == .live else { return }
        nextID += 1
        transcript.append((id: nextID, prompt: prompt, reply: ""))
        Task {
            try? await connection.send(json: [
                "type": "conversation.item.create",
                "item": ["type": "message", "role": "user", "content": [["type": "input_text", "text": .string(prompt)]]],
            ])
            try? await connection.send(json: ["type": "response.create"])
        }
    }

    private func listen(to connection: RealtimeConnection) async {
        do {
            for try await event in connection.events {
                eventCount += 1
                let type = (try? JSONValue(encoding: event))?["type"]?.stringValue ?? "event"
                nextID += 1
                events.insert((id: nextID, type: type), at: 0)
                if events.count > 7 { events.removeLast() }
                switch event {
                case .sessionCreated, .sessionUpdated:
                    status = .live
                case .responseOutputTextDelta(let delta):
                    if !transcript.isEmpty { transcript[transcript.count - 1].reply += delta.delta }
                case .error(let error):
                    errorText = error.error.message
                default:
                    break
                }
            }
        } catch {
            errorText = error.localizedDescription
        }
        status = .offline
    }
}

struct ShowcaseRealtimeView: View {
    @StateObject private var model = RealtimeConsoleModel()

    private let prompts = ["Greet Swift developers", "Give me a fun fact", "Tell a 2-line story"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(model.status == .live ? Color.green : model.status == .connecting ? .orange : .gray)
                        .frame(width: 10, height: 10)
                    Text(model.status.rawValue).font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
                Spacer()
                Text("\(model.eventCount) events")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Button(model.status == .offline ? "Connect" : "Disconnect") {
                    model.status == .offline ? model.connect() : model.disconnect()
                }
                .buttonStyle(.borderedProminent)
                .tint(model.status == .offline ? .teal : .gray)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(model.transcript, id: \.id) { turn in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(turn.prompt).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                            Text(turn.reply.isEmpty ? "…" : turn.reply).font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    if model.transcript.isEmpty {
                        Text(model.status == .live ? "Pick a prompt below." : "Connect to open a WebSocket to the Realtime API.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("SERVER EVENTS").font(.caption2.weight(.bold)).foregroundStyle(.green.opacity(0.8))
                ForEach(model.events, id: \.id) { event in
                    Text("← \(event.type)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.green)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)
            .padding(12)
            .background(Color.black.opacity(0.9), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .animation(.easeOut(duration: 0.15), value: model.eventCount)
            .padding(.horizontal)

            if let error = model.errorText {
                Text(error).font(.footnote).foregroundStyle(.red).padding(.horizontal)
            }

            SuggestionChips(suggestions: prompts) { model.ask($0) }
                .disabled(model.status != .live)
                .opacity(model.status == .live ? 1 : 0.4)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .navigationTitle("Realtime")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { model.disconnect() }
    }
}
