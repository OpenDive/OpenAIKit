public enum OpenAIError: Error {
    case noApiKey
    case noBody
    case promptThreshold
    case invalidUrl
    case invalidPrompt
}
