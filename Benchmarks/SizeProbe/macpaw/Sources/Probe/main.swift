import OpenAI
let client = OpenAI(apiToken: "sk")
let response: ResponseObject = try await client.responses.createResponse(query: CreateModelResponseQuery(input: .textInput("Hi"), model: "gpt-6.2-astra"))
print(response.output.count)
for try await chunk in client.chatsStream(query: ChatQuery(messages: [.user(.init(content: .string("Hi")))], model: "gpt-6.2-astra")) {
    print(chunk.choices.first?.delta.content ?? "", terminator: "")
}
