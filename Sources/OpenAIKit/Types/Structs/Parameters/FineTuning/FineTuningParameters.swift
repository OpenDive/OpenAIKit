import Foundation

public struct FineTuningJobCreateParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case model
        case trainingFileID = "training_file"
        case validationFileID = "validation_file"
        case suffix
    }

    public var model: String
    public var trainingFileID: String
    public var validationFileID: String?
    public var suffix: String?

    public init(
        model: String,
        trainingFileID: String,
        validationFileID: String? = nil,
        suffix: String? = nil
    ) {
        self.model = model
        self.trainingFileID = trainingFileID
        self.validationFileID = validationFileID
        self.suffix = suffix
    }
}
