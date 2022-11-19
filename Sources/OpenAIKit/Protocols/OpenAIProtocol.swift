public protocol OpenAIProtocol {
    func listModels() async throws -> ListModelResponse
    
    func retrieveModel(modelId id: String) async throws -> Model
    
    func generateCompletion(parameters param: CompletionParameters) async throws -> CompletionResponse
    
    func generateEdit(parameters param: EditParameters) async throws -> EditResponse
    
    func createImage(parameters param: ImageParameters) async throws -> ImageResponse
    
    func generateImageEdits(parameters param: ImageEditParameters) async throws -> ImageResponse
    
    func generateImageVariations(parameters param: ImageVariationParameters) async throws -> ImageResponse
    
    func createEmbeddings(parameters param: EmbeddingsParameters) async throws -> EmbeddingsResponse
    
    func listFiles() async throws -> ListFilesResponse
    
    func uploadFile(parameters param: UploadFileParameters) async throws -> File
    
    func deleteFile(fileId id: String) async throws -> DeleteObject
    
    func retrieveFile(fileId id: String) async throws -> File
    
    func retrieveFileContent(fileId id: String) async throws -> [FineTuneTraining]
    
    func createFineTune(parameters param: CreateFineTuneParameters) async throws -> FineTune
    
    func listFineTunes() async throws -> ListFineTuneResponse
    
    func retrieveFineTune(fineTune id: String) async throws -> FineTune
    
    func cancelFineTune(fineTune id: String) async throws -> FineTune
    
    func checkContentPolicy(parameters param: ContentPolicyParameters) async throws -> ContentPolicyResponse
}
