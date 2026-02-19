import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public class OpenAIResource {
    internal unowned let client: OpenAI

    internal init(_ client: OpenAI) {
        self.client = client
    }
}

// MARK: Top-level resources

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class CompletionsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ChatResource: OpenAIResource {
    public lazy var completions = ChatCompletionsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class EmbeddingsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class FilesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ImagesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class AudioResource: OpenAIResource {
    public lazy var speech = AudioSpeechResource(client)
    public lazy var transcriptions = AudioTranscriptionsResource(client)
    public lazy var translations = AudioTranslationsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ModerationsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ModelsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class FineTuningResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class VectorStoresResource: OpenAIResource {
    public lazy var files = VectorStoreFilesResource(client)
    public lazy var fileBatches = VectorStoreFileBatchesResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class WebhooksResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BatchesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class UploadsResource: OpenAIResource {
    public lazy var parts = UploadPartsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ResponsesResource: OpenAIResource {
    public lazy var inputItems = ResponseInputItemsResource(client)
    public lazy var inputTokens = ResponseInputTokensResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class RealtimeResource: OpenAIResource {
    public lazy var calls = RealtimeCallsResource(client)
    public lazy var clientSecrets = RealtimeClientSecretsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ConversationsResource: OpenAIResource {
    public lazy var items = ConversationItemsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class EvalsResource: OpenAIResource {
    public lazy var runs = EvalRunsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ContainersResource: OpenAIResource {
    public lazy var files = ContainerFilesResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class SkillsResource: OpenAIResource {
    public lazy var versions = SkillVersionsResource(client)
    public lazy var content = SkillContentResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class VideosResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaResource: OpenAIResource {
    public lazy var assistants = BetaAssistantsResource(client)
    public lazy var threads = BetaThreadsResource(client)
    public lazy var chatkit = BetaChatKitResource(client)
    public lazy var realtime = BetaRealtimeResource(client)
}

// MARK: Nested resources

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ChatCompletionsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class AudioSpeechResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class AudioTranscriptionsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class AudioTranslationsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class VectorStoreFilesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class VectorStoreFileBatchesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class UploadPartsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ResponseInputItemsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ResponseInputTokensResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class RealtimeCallsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class RealtimeClientSecretsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ConversationItemsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class EvalRunsResource: OpenAIResource {
    public lazy var outputItems = EvalRunOutputItemsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class EvalRunOutputItemsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ContainerFilesResource: OpenAIResource {
    public lazy var content = ContainerFileContentResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ContainerFileContentResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class SkillVersionsResource: OpenAIResource {
    public lazy var content = SkillVersionContentResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class SkillVersionContentResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class SkillContentResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaAssistantsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaThreadsResource: OpenAIResource {
    public lazy var messages = BetaThreadMessagesResource(client)
    public lazy var runs = BetaThreadRunsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaThreadMessagesResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaThreadRunsResource: OpenAIResource {
    public lazy var steps = BetaThreadRunStepsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaThreadRunStepsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaChatKitResource: OpenAIResource {
    public lazy var sessions = BetaChatKitSessionsResource(client)
    public lazy var threads = BetaChatKitThreadsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaChatKitSessionsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaChatKitThreadsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaRealtimeResource: OpenAIResource {
    public lazy var sessions = BetaRealtimeSessionsResource(client)
    public lazy var transcriptionSessions = BetaRealtimeTranscriptionSessionsResource(client)
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaRealtimeSessionsResource: OpenAIResource {}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class BetaRealtimeTranscriptionSessionsResource: OpenAIResource {}
