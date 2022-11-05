public protocol OpenAIProtocol {
    func generateImages(parameters param: ImageParameters) async throws -> ImageResponse
}
