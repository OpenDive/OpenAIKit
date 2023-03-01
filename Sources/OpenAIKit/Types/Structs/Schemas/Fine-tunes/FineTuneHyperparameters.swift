//
//  FineTuneHyperparamters.swift
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

/// The hyperparameters used to tweak the Fine-tune model.
public struct FineTuneHyperparamters: Codable {
    enum CodingKeys: String, CodingKey {
        case batchSize = "batch_size"
        case learningRateMultiplier = "learning_rate_multiplier"
        case nEpochs = "n_epochs"
        case promptLossWeight = "prompt_loss_weight"
    }

    /// The batch size to use for training.
    ///
    /// The batch size is the number of training examples used to train a single forward and backward pass.
    ///
    /// By default, the batch size will be dynamically configured to be ~0.2% of the number of examples in the training set,
    /// capped at 256 - in general, we've found that larger batch sizes tend to work better for larger datasets.
    public let batchSize: Int?

    /// The learning rate multiplier to use for training.
    ///
    /// The fine-tuning learning rate is the original learning rate used for pretraining multiplied by this value.
    ///
    /// By default, the learning rate multiplier is the 0.05, 0.1, or 0.2 depending on final `batch_size`
    /// (larger learning rates tend to perform better with larger batch sizes).
    /// We recommend experimenting with values in the range 0.02 to 0.2 to see what produces the best results.
    public let learningRateMultiplier: Double?

    /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
    public let nEpochs: Int

    /// The weight to use for loss on the prompt tokens.
    ///
    /// This controls how much the model tries to learn to generate the prompt
    /// (as compared to the completion which always has a weight of 1.0), and can add a stabilizing effect to training when completions are short.
    ///
    /// If prompts are extremely long (relative to completions), it may make sense to reduce this weight so as to avoid over-prioritizing learning the prompt.
    public let promptLossWeight: Double
}
