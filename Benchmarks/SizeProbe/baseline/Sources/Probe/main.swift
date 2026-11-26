import Foundation
let url = URL(string: "https://api.openai.com/v1/responses")!
var request = URLRequest(url: url)
request.httpBody = try JSONEncoder().encode(["model": "gpt-6.2-astra", "input": "Hi"])
let (data, _) = try await URLSession.shared.data(for: request)
print(try JSONSerialization.jsonObject(with: data))
