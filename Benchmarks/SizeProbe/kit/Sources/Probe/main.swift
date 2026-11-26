import OpenAIKit
let client = OpenAI(apiKey: "sk")
let response = try await client.responses.create(CreateResponse(model: "gpt-6.2-astra", input: "Hi"))
print(response.outputText)
for try await chunk in client.chat.completions.createStream(CreateChatCompletionRequest(model: "gpt-6.2-astra", messages: [.user(text: "Hi")])) {
    print(chunk.contentDelta ?? "", terminator: "")
}
