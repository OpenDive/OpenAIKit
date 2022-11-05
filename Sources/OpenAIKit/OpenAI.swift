import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public class OpenAI {
    private var apiKey: String?
    
    public init(key apiKey: String? = nil) {
        self.apiKey = apiKey
    }
    
    private func getServerUrl(path: String) async throws -> URL {
        guard let result = URL(string: "https://api.openai.com/v1\(path)") else {
            throw OpenAIError.invalidUrl
        }
        
        return result
    }
}

extension OpenAI: OpenAIProtocol {
    public func generateImages(parameters param: ImageParameters) async throws -> ImageResponse {
        let serverUrl = try await getServerUrl(path: "/images/generations")
        return try await URLSession.shared.decodeUrl(with: serverUrl, apiKey: apiKey, body: param.body)
    }
}
