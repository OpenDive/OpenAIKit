//
//  File.swift
//  
//
//  Copyright (c) 2022 MarcoDotIO
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

public struct CreateFineTuneParameters {
    public var trainingFile: String
    public var validationFile: String?
    public var model: String
    public var nEpochs: Int
    public var batchSize: Int?
    public var learningRateMultiplier: Double?
    public var promptLossWeight: Double
    public var computeClassificationMetrics: Bool
    public var classificationNClasses: Int?
    public var classificationPositiveClass: String?
    public var classificationBetas: [Double]?
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
    
    public var body: [String: Any] {
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
