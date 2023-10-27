//
//  CreateChatFunctionCallExample.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 10/9/23.
//

import SwiftUI
import OpenAIKit

struct CreateChatFunctionCallExample: View {
    @State private var isCompleting: Bool = false
    @State private var weatherInfo: WeatherInfo? = nil

    enum TemperatureUnit: String, Codable {
        case fahrenheit
        case celsius
    }

    struct WeatherInfo: Codable {
        let location: String
        let temperature: String
        let unit: TemperatureUnit
        let forecast: [String]
    }

    func getCurrentWeather(location: String, unit: TemperatureUnit = .fahrenheit) -> WeatherInfo {
        return WeatherInfo(location: location, temperature: "72", unit: unit, forecast: ["sunny", "windy"])
    }

    let messages: [ChatMessage] = [ChatMessage(role: .user, content: "What's the weather like in Boston?")]

    let functions: [Function] = [
        Function(
            name: "getCurrentWeather",
            description: "Get the current weather in a given location",
            parameters: Parameters(
                type: "object",
                properties: [
                    "location": ParameterDetail(type: "string", description: "The city and state, e.g. San Francisco, CA"),
                    "unit": ParameterDetail(type: "string", enumValues: ["fahrenheit", "celsius"])
                ],
                required: ["location"]
            )
        )
    ]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text("\(message.role.rawValue.capitalized): \(message.content ?? "NO CONTENT")")
                        .padding(.vertical, 10)
                }
            }
            .padding(20)

            if isCompleting {
                VStack {
                    if let weatherInfo {
                        Text("Assistant: The current weather in \(weatherInfo.location) is \(weatherInfo.temperature) degrees \(weatherInfo.unit.rawValue).")
                    } else {
                        Text("Assistant: ...")
                    }
                }
                .padding()
            } else {
                VStack {
                    Button {
                        isCompleting = true

                        Task {
                            do {
                                // ⚠️🔑 NEVER store OpenAI API keys directly in code. Use environment variables or secrets management. Avoid git commits of keys! 🔑⚠️
                                let config = Configuration(
                                    organizationId: "INSERT-ORGANIZATION-ID",
                                    apiKey: "INSERT-API-KEY"
                                )
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(
                                    model: .chatGPTTurbo,
                                    messages: messages,
                                    functionCall: "auto",
                                    functions: functions
                                )

                                let chatCompletion = try await openAI.generateChatCompletion(
                                    parameters: chatParameters
                                )

                                if let message = chatCompletion.choices[0].message, let functionCall = message.functionCall {
                                    let jsonString = functionCall.arguments
                                    if let data = jsonString.data(using: .utf8) {
                                        do {
                                            if 
                                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                                let location = json["location"] as? String
                                            {
                                                self.weatherInfo = self.getCurrentWeather(location: location)
                                            }
                                        } catch {
                                            print("Error parsing JSON: \(error)")
                                        }
                                    }
                                }
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 270, height: 50)
                            .background(.blue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                    }
                }
            }
        }

        Spacer()
    }
}

struct CreateChatFunctionCallExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateChatFunctionCallExample()
        }
    }
}
