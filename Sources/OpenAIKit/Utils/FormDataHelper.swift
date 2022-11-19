//
//  FormDataHelper.swift
//  OpenAIKit
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

struct FormDataHelper {
    private let boundary: String = UUID().uuidString
    private let formBody = NSMutableData()

    let formUrl: URL

    init(formUrl: URL) {
        self.formUrl = formUrl
    }

    func addTextField(named name: String, value: String) {
        self.formBody.append(textFormField(named: name, value: value))
    }

    func addDataField(named name: String, formData: FormData) {
        self.formBody.append(dataFormField(named: name, formData: formData))
    }

    func asURLRequest(apiKey: String) -> URLRequest {
        var request = URLRequest(url: formUrl)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        self.formBody.append("--\(boundary)--")
        request.httpBody = self.formBody as Data
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(apiKey)"]

        return request
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    private func dataFormField(named name: String, formData: FormData) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(formData.fileName)\"\r\n")
        fieldData.append("Content-Type: \(formData.mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(formData.data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
}
