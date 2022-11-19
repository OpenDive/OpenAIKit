//
//  File 2.swift
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

public struct FineTune: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case model
        case createdAt = "created_at"
        case events
        case fineTunedModel = "fine_tuned_model"
        case hyperparams
        case organizationId = "organization_id"
        case resultFiles = "result_files"
        case status
        case validationFiles = "validation_files"
        case trainingFiles = "training_files"
        case updatedAt = "updated_at"
    }
    
    public let id: String
    public let object: OpenAIObject
    public let model: String
    public let createdAt: Int
    public let events: [FineTuneEvent]
    public let fineTunedModel: String?
    public let hyperparams: FineTuneHyperparamters
    public let organizationId: String
    public let resultFiles: [File]
    public let status: FineTuneStatus
    public let validationFiles: [File]
    public let trainingFiles: [File]
    public let updatedAt: Int
}