//
//  URLSessionExtension.swift
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

import Foundation

#if os(Linux) || SERVER
import FoundationNetworking
#endif

// Extensions used to help better streamline the main OpenAIKit class.
// Most are private to help with having better Access Control.
class OpenAIKitSession {
    /// Shared Singleton object for use within the OpenAIKit API Module
    internal static let shared = OpenAIKitSession()

    /// Conforming to the Singleton Design Pattern
    private init() {  }

    /// Uses URLRequest to set up a HTTPMethod, and implement default values for the method cases.
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    /// Decode a data object using `JSONDecoder.decode()`.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - data: `Data` input object.
    ///   - keyDecodingStrategy: Default is `.useDefaultKeys`.
    ///   - dataDecodingStrategy: Default is `.deferredToData`.
    ///   - dateDecodingStrategy: Default is `.deferredToDate`.
    /// - Returns: Decoded data of `T` type, or throws an `OpenAIErrorRaesponse` object.
    private func decodeData<T: Decodable>(
        _ type: T.Type = T.self,
        with data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        guard let decoded = try? decoder.decode(type, from: data) else {
            throw try decoder.decode(OpenAIErrorResponse.self, from: data)
        }
        return decoded
    }

    /// Takes a `URL` input, along with header information, and converts it into a `URLRequest`;
    /// and fetches the data using an `Async` `Await` wrapper for the older `dataTask` handler.
    /// - Parameters:
    ///   - url: `URL` to convert to a `URLRequest`.
    ///   - method: Input can be either a `.get` or a `.post` method, with the default being `.post`.
    ///   - headers: Header data for the request that uses a `[string:string]` dictionary,
    ///   and the default is set to an empty dictionary.
    ///   - body: Body data that defaults to `nil`.
    /// - Returns: The data that was fetched typed as a `Data` object.
    private func asyncData(
        with url: URL,
        method: HTTPMethod = .post,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws -> Data {
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body

        headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        return try await asyncData(with: request)
    }

    /// An Async Await wrapper for the older `dataTask` handler.
    /// - Parameter request: `URLRequest` to be fetched from.
    /// - Returns: A Data object fetched from the` URLRequest`.
    private func asyncData(with request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { (con: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: data)
                } else {
                    con.resume(returning: Data())
                }
            }

            task.resume()
        }
    }
    
    /// Used for parsing `.jsonl` files when retrieving fine-tuning files from OpenAI's server.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    /// - Returns: The decoded object of array type `T`.
    public func retrieveJsonLine<T: Decodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil
    ) async throws -> [T] {
        guard let apiKey = apiKey else { throw OpenAIError.noApiKey }

        let jsonDecoder = JSONDecoder()

        let genData = try await self.asyncData(
            with: url,
            method: .get,
            headers: ["Authorization": "Bearer \(apiKey)"]
        )

        let genString = String(decoding: genData, as: UTF8.self)

        return try genString.components(separatedBy: .newlines)
            .filter { $0 != "" }
            .compactMap { gen -> T? in
                guard let data = gen.data(using: .utf8) else {
                    throw OpenAIError.invalidData
                }
                return try? jsonDecoder.decode(T.self, from: data)
            }
    }

    /// Decode a `URL` to the type `T` using either `asyncData()` for the Production Server;
    /// or using `decode()` for the Mock Server.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - with: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the server.
    ///   - body: The POST body used to add parameters, defaults to `nil`.
    ///   - method: The method used for the function, defaults to `.post`.
    ///   - bodyRequired: Is the body required or not, used for `.get` and `.delete`, defaults to `false`.
    ///   - formSubmission: Is the body actually a form submission? Used for image submissionss, defaults to `false`.
    /// - Returns: The decoded object of type `T`.
    public func decodeUrl<T: Decodable>(
        _ type: T.Type = T.self,
        with url: URL,
        apiKey: String? = nil,
        body: [String: Any]? = nil,
        method: HTTPMethod = .post,
        bodyRequired: Bool = true,
        formSubmission: Bool = false
    ) async throws -> T {
        guard let apiKey = apiKey else { throw OpenAIError.noApiKey }

        if bodyRequired {
            guard let body = body else { throw OpenAIError.noBody }

            if formSubmission {
                let formRequest = FormDataHelper(formUrl: url)

                body.forEach { (key, value) in
                    if let dataValue = value as? FormData {
                        formRequest.addDataField(named: key, formData: dataValue)
                    } else {
                        formRequest.addTextField(named: key, value: "\(value)")
                    }
                }

                let request = formRequest.asURLRequest(apiKey: apiKey)
                let data = try await asyncData(with: request)

                return try await self.decodeData(with: data)
            } else {
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                let data = try await self.asyncData(
                    with: url, method: method,
                    headers: ["Authorization": "Bearer \(apiKey)"],
                    body: jsonData
                )

                return try await self.decodeData(with: data)
            }
        }

        if !bodyRequired && !formSubmission {
            let data = try await self.asyncData(
                with: url,
                method: method,
                headers: ["Authorization": "Bearer \(apiKey)"]
            )

            return try await self.decodeData(with: data)
        }

        throw OpenAIError.noBody
    }
}
