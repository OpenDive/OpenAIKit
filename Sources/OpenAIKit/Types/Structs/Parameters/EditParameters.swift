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

public struct EditParameters {
    public var model: String
    public var input: String
    public var instruction: String
    public var numberOfEdits: Int
    public var temperature: Double
    public var topP: Double
    
    public init(
        model: String,
        input: String = "\"",
        instruction: String,
        numberOfEdits: Int = 1,
        temperature: Double = 1.0,
        topP: Double = 1.0
    ) {
        self.model = model
        self.input = input
        self.instruction = instruction
        self.numberOfEdits = numberOfEdits
        self.temperature = temperature
        self.topP = topP
    }
    
    public var body: [String: Any] {
        return [
            "model": self.model,
            "input": self.input,
            "instruction": self.instruction,
            "n": self.numberOfEdits,
            "temperature": self.temperature,
            "top_p": self.topP
        ]
    }
}
