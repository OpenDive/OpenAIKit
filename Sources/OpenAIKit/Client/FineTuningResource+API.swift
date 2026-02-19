import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension FineTuningJobsResource {
    func create(parameters: FineTuningJobCreateParameters) async throws -> FineTuningJobObject {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            body: parameters
        )
    }

    func list() async throws -> FineTuningJobListResponse {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func retrieve(id: String) async throws -> FineTuningJobObject {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs/\(id)")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func cancel(id: String) async throws -> FineTuningJobObject {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs/\(id)/cancel")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .post,
            bodyRequired: false
        )
    }

    func listEvents(jobID: String) async throws -> FineTuningJobEventListResponse {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs/\(jobID)/events")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }

    func listCheckpoints(jobID: String) async throws -> FineTuningCheckpointListResponse {
        let url = try client.getServerUrl(path: "/fine_tuning/jobs/\(jobID)/checkpoints")
        return try await OpenAIKitSession.shared.decodeUrl(
            with: url,
            configuration: client.configuration,
            method: .get,
            bodyRequired: false
        )
    }
}
