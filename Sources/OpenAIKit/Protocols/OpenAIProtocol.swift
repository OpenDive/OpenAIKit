public protocol OpenAIProtocol {
    func generateImages(parameters param: ImageParameters) async throws -> ImageResponse
    
    func checkContentPolicy(parameters param: ContentPolicyParameters) async throws -> ContentPolicyResponse
    
    func listModels() async throws -> ListModelResponse
}
