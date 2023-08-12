//
//  CreateFineTuneParameters.swift
//  OpenAIKit
//
//  Copyright (c) 2023 MarcoDotIO
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// Parameter struct used for creating Fine-tune jobs.
public struct CreateFineTuneParameters {
    /// The ID of an uploaded file that contains training data.
    ///
    /// See [upload file](https://beta.openai.com/docs/api-reference/files/upload) for how to upload a file.
    ///
    /// Your dataset must be formatted as a JSONL file, where each training example is a JSON object with the keys "prompt" and "completion".
    /// Additionally, you must upload your file with the purpose `fine-tune`.
    ///
    /// See the [fine-tuning guide](https://beta.openai.com/docs/guides/fine-tuning/creating-training-data) for more details.
    public var trainingFile: String

    /// The ID of an uploaded file that contains validation data.
    ///
    /// If you provide this file, the data is used to generate validation metrics periodically during fine-tuning.
    /// These metrics can be viewed in the [fine-tuning results file](https://beta.openai.com/docs/guides/fine-tuning/analyzing-your-fine-tuned-model).
    /// Your train and validation data should be mutually exclusive.
    ///
    /// Your dataset must be formatted as a JSONL file, where each validation example is a JSON object with the keys "prompt" and "completion".
    /// Additionally, you must upload your file with the purpose `fine-tune`
    ///
    /// See the [fine-tuning guide](https://beta.openai.com/docs/guides/fine-tuning/creating-training-data) for more details..
    public var validationFile: String?

    /// The name of the base model to fine-tune. You can select one of "ada", "babbage", "curie", "davinci", or a fine-tuned model created after 2022-04-21.
    ///
    /// To learn more about these models, see the [Models](https://beta.openai.com/docs/models) documentation.
    public var model: String

    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    public var nEpochs: Int

    /// The batch size to use for training.
    ///
    /// The batch size is the number of training examples used to train a single forward and backward pass.
    ///
    /// By default, the batch size will be dynamically configured to be ~0.2% of the number of examples in the training set,
    /// capped at 256 - in general, we've found that larger batch sizes tend to work better for larger datasets.
    public var batchSize: Int?

    /// The learning rate multiplier to use for training.
    ///
    /// The fine-tuning learning rate is the original learning rate used for pretraining multiplied by this value.
    ///
    /// By default, the learning rate multiplier is the 0.05, 0.1, or 0.2 depending on final `batch_size`
    /// (larger learning rates tend to perform better with larger batch sizes).
    /// We recommend experimenting with values in the range 0.02 to 0.2 to see what produces the best results.
    public var learningRateMultiplier: Double?

    /// The weight to use for loss on the prompt tokens.
    ///
    /// This controls how much the model tries to learn to generate the prompt
    /// (as compared to the completion which always has a weight of 1.0), and can add a stabilizing effect to training when completions are short.
    ///
    /// If prompts are extremely long (relative to completions), it may make sense to reduce this weight so as to avoid over-prioritizing learning the prompt.
    public var promptLossWeight: Double

    /// If set, we calculate classification-specific metrics such as accuracy and F-1 score using the validation set at the end of every epoch.
    ///
    /// These metrics can be viewed in the [results file](https://beta.openai.com/docs/guides/fine-tuning/analyzing-your-fine-tuned-model).
    ///
    /// In order to compute classification metrics, you must provide a `validation_file`.
    /// Additionally, you must specify `classification_n_classes` for multiclass classification or `classification_positive_class` for binary classification.
    public var computeClassificationMetrics: Bool

    /// The number of classes in a classification task.
    ///
    /// This parameter is required for multiclass classification.
    public var classificationNClasses: Int?

    /// The positive class in binary classification.
    ///
    /// This parameter is needed to generate precision, recall, and F1 metrics when doing binary classification.
    public var classificationPositiveClass: String?

    /// If this is provided, we calculate F-beta scores at the specified beta values.
    ///
    /// The F-beta score is a generalization of F-1 score. This is only used for binary classification.
    ///
    /// With a beta of 1 (i.e. the F-1 score), precision and recall are given the same weight.
    /// A larger beta score puts more weight on recall and less on precision.
    /// A smaller beta score puts more weight on precision and less on recall.
    public var classificationBetas: [Double]?

    /// A string of up to 40 characters that will be added to your fine-tuned model name.
    ///
    /// For example, a `suffix` of "custom-model-name" would produce a model name like
    /// `ada:ft-your-org:custom-model-name-2022-02-15-04-21-04`.
    public var suffix: String?

    public init(
        trainingFile: String,
        validationFile: String? = nil,
        model: String = "curie",
        nEpochs: Int = 4,
        batchSize: Int? = nil,
        learningRateMultiplier: Double? = nil,
        promptLossWeight: Double = 0.01,
        computeClassificationMetrics: Bool = false,
        classificationNClasses: Int? = nil,
        classificationPositiveClass: String? = nil,
        classificationBetas: [Double]? = nil,
        suffix: String? = nil
    ) {
        self.trainingFile = trainingFile
        self.validationFile = validationFile
        self.model = model
        self.nEpochs = nEpochs
        self.batchSize = batchSize
        self.learningRateMultiplier = learningRateMultiplier
        self.promptLossWeight = promptLossWeight
        self.computeClassificationMetrics = computeClassificationMetrics
        self.classificationNClasses = classificationNClasses
        self.classificationPositiveClass = classificationPositiveClass
        self.classificationBetas = classificationBetas
        self.suffix = suffix
    }

    /// The body of the URL used for OpenAI API requests.
    internal var body: [String: Any] {
        var result: [String: Any] = [
            "training_file": self.trainingFile,
            "model": self.model,
            "n_epochs": self.nEpochs,
            "prompt_loss_weight": self.promptLossWeight,
            "compute_classification_metrics": self.computeClassificationMetrics
        ]

        if let validationFile = self.validationFile {
            result["validation_file"] = validationFile
        }

        if let batchSize = self.batchSize {
            result["batch_size"] = batchSize
        }

        if let learningRateMultiplier = self.learningRateMultiplier {
            result["learning_rate_multiplier"] = learningRateMultiplier
        }

        if let classificationNClasses = self.classificationNClasses {
            result["classification_n_classes"] = classificationNClasses
        }

        if let classificationPositiveClass = self.classificationPositiveClass {
            result["classification_positive_class"] = classificationPositiveClass
        }

        if let classificationBetas = self.classificationBetas {
            result["classification_betas"] = classificationBetas
        }

        if let suffix = self.suffix {
            result["suffix"] = suffix
        }

        return result
    }
}
