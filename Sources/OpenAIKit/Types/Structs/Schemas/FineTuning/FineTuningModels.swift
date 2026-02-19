import Foundation

public struct FineTuningJobObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case model
        case status
        case createdAt = "created_at"
        case fineTunedModel = "fine_tuned_model"
    }

    public let id: String
    public let object: String?
    public let model: String?
    public let status: String?
    public let createdAt: Int?
    public let fineTunedModel: String?
}

public struct FineTuningJobListResponse: Codable {
    public let object: String
    public let data: [FineTuningJobObject]
}

public struct FineTuningJobEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case level
        case message
    }

    public let id: String?
    public let object: String?
    public let createdAt: Int?
    public let level: String?
    public let message: String?
}

public struct FineTuningJobEventListResponse: Codable {
    public let object: String
    public let data: [FineTuningJobEvent]
}

public struct FineTuningCheckpointObject: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case fineTunedModelCheckpoint = "fine_tuned_model_checkpoint"
    }

    public let id: String
    public let object: String?
    public let createdAt: Int?
    public let fineTunedModelCheckpoint: String?
}

public struct FineTuningCheckpointListResponse: Codable {
    public let object: String
    public let data: [FineTuningCheckpointObject]
}
