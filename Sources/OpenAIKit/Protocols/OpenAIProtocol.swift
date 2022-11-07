public protocol OpenAIProtocol {
    func listModels() async throws -> ListModelResponse
    
    func retrieveModel(modelId id: String) async throws -> Model
    
    func generateImages(parameters param: ImageParameters) async throws -> ImageResponse
    
    func checkContentPolicy(parameters param: ContentPolicyParameters) async throws -> ContentPolicyResponse
}
