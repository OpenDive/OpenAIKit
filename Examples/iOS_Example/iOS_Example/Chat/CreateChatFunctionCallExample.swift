//
//  CreateChatFunctionCallExample.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 10/9/23.
//

import SwiftUI
import OpenAIKit

/// Function calling with the Responses API: the model asks for a function call, the app runs it,
/// and the result goes back to the model so it can answer in plain language.
struct CreateChatFunctionCallExample: View {
    @State private var isCompleting: Bool = false
    @State private var weatherInfo: WeatherInfo? = nil
    @State private var responseText: String? = nil

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

    /// The arguments the model sends for `get_current_weather`.
    struct WeatherArguments: Decodable {
        let location: String
        let unit: TemperatureUnit
    }

    func getCurrentWeather(location: String, unit: TemperatureUnit = .fahrenheit) -> WeatherInfo {
        return WeatherInfo(location: location, temperature: "72", unit: unit, forecast: ["sunny", "windy"])
    }

    let messages = [ExampleMessage(role: .user, content: "What's the weather like in Boston?")]

    /// The function the model may call. With `strict: true` every property must be listed in
    /// `required` and `additionalProperties` must be `false`.
    let tools: [Tool] = [
        .function(
            FunctionTool(
                name: "get_current_weather",
                description: "Get the current weather in a given location",
                parameters: [
                    "type": "object",
                    "properties": [
                        "location": [
                            "type": "string",
                            "description": "The city and state, e.g. San Francisco, CA"
                        ],
                        "unit": [
                            "type": "string",
                            "enum": ["fahrenheit", "celsius"]
                        ]
                    ],
                    "required": ["location", "unit"],
                    "additionalProperties": false
                ],
                strict: true
            )
        )
    ]

    var body: some View {
        VStack {
            ExampleConversationView(messages: messages)

            if isCompleting {
                VStack(alignment: .leading, spacing: 12) {
                    if let weatherInfo {
                        Text("Function result: \(weatherInfo.temperature) degrees \(weatherInfo.unit.rawValue) in \(weatherInfo.location), \(weatherInfo.forecast.joined(separator: " and ")).")
                            .foregroundStyle(.secondary)
                    }

                    if let responseText {
                        Text("Assistant: \(responseText)")
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
                                let openAI = OpenAI(Configuration(apiKey: "INSERT-API-KEY"))

                                // 1. Send the question together with the tool definition.
                                let first = try await openAI.responses.create(
                                    CreateResponse(
                                        model: "gpt-6.2-astra",
                                        input: .inputItemList(messages.map(\.inputItem)),
                                        tools: tools
                                    )
                                )

                                // 2. Run every function call the model asked for.
                                var outputs: [InputItem] = []
                                for call in first.functionCalls where call.name == "get_current_weather" {
                                    let arguments = try call.decodeArguments(as: WeatherArguments.self)
                                    let weather = getCurrentWeather(location: arguments.location, unit: arguments.unit)
                                    self.weatherInfo = weather

                                    let result = String(decoding: try JSONEncoder().encode(weather), as: UTF8.self)
                                    outputs.append(
                                        .item(.functionCallOutput(FunctionCallOutputItemParam(output: .string(result), callID: call.callID)))
                                    )
                                }

                                guard !outputs.isEmpty else {
                                    // The model answered without calling the function.
                                    self.responseText = first.outputText
                                    return
                                }

                                // 3. Send the results back, continuing the stored response.
                                let final = try await openAI.responses.create(
                                    CreateResponse(
                                        model: "gpt-6.2-astra",
                                        input: .inputItemList(outputs),
                                        previousResponseID: first.id,
                                        tools: tools
                                    )
                                )

                                self.responseText = final.outputText
                            } catch {
                                print("ERROR DETAILS - \(error)")
                            }
                        }
                    } label: {
                        Text("Generate Response")
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
