//
//  File.swift
//  
//
//  Created by Marcus Arnett on 11/4/22.
//

public struct ImageParameters {
    public var prompt: String
    public var numberOfImages: Int
    public var resolution: ImageResolutions
    public var responseFormat: ResponseFormat
    public var user: String?
    
    public init(
        prompt: String,
        @Clamped(range: 1...10) numberofImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.numberOfImages = numberofImages
        self.resolution = resolution
        self.responseFormat = responseFormat
        self.user = user
    }
    
    public var body: [String: Any] {
        var result: [String: Any] = ["prompt": self.prompt,
                                     "n": self.numberOfImages,
                                     "size": self.resolution.rawValue,
                                     "response_format": self.responseFormat.rawValue]
        if let user = self.user {
            result["user"] = user
        }
        
        return result
    }
}
