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

import Foundation

public struct ImageEditParameters {
    public var image: FormData
    public var mask: FormData
    public var prompt: String
    public var numberOfImages: Int
    public var resolution: ImageResolutions
    public var responseFormat: ResponseFormat
    public var user: String?
    
    public init(
        image: Data,
        imageName: String,
        mask: Data,
        maskName: String,
        prompt: String,
        numberOfImages: Int = 1,
        resolution: ImageResolutions = .large,
        responseFormat: ResponseFormat = .url,
        user: String? = nil
    ) {
        self.image = FormData(data: image, mimeType: "image/png", fileName: imageName)
        self.mask = FormData(data: mask, mimeType: "image/png", fileName: maskName)
        self.prompt = prompt
        self.numberOfImages = numberOfImages
        self.resolution = resolution
        self.responseFormat = responseFormat
        self.user = user
    }
    
    public var body: [String: Any] {
        var result: [String: Any] = ["image": self.image,
                                     "mask": self.mask,
                                     "prompt": self.prompt,
                                     "n": self.numberOfImages,
                                     "size": self.resolution.rawValue,
                                     "response_format": self.responseFormat.rawValue]
        if let user = self.user {
            result["user"] = user
        }
        
        return result
    }
}
