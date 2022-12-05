# OpenAIKit

[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-green?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS-green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Swift](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml)

OpenAIKit is a community-maintained API for the OpenAI REST endpoint used to get output data from Dall-E 2 and GPT-3 models.

- [Features](#features)
- [ToDo](#todo)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
    - [SPM Through Xcode Project](#spm-through-xcode-project)
    - [SPM Through Xcode Package](#spm-through-xcode-package)
- [Using OpenAIKit](#using-openaikit)
- [Development and Testing](#development-and-testing)
- [Next Steps](#next-steps)
- [Credits](#credits)
- [License](#license)

## Features

- [x] Generate new, edited, and variations of images using Dall-E 2.
- [x] Generate edits and completions using GPT-3.
- [x] List avaiable models for use with GPT-3.
- [x] Retrieve embeddings for GPT-3 prompts.
- [x] Upload and view training set files for Fine-tuning.
- [x] Generate and use Fine-tuned models.
- [x] View whether a prompt is flagged by the Moderations endpoint or not.
- [x] Comprehensive Unit and Integration Test coverage.
- [x] Swift Concurrency Support back to iOS 13, macOS 10.15, tvOS 13, and watchOS 6.
- [x] Complete documentation of OpenAIKit.

## ToDo

- [ ] Implement data streaming for Fine-Tune and GPT-3 event streams.

## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ | 5.5 | [Swift Package Manager](#swift-package-manager) | Fully Tested |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) allows for developers to easily integrate packages into their Xcode projects and packages; and is also fully integrated into the `swift` compiler.

#### SPM Through XCode Project

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/marcodotio/OpenAIKit.git`
* Select "Up to next Major" with "1.1.0"

#### SPM Through Xcode Package

Once you have your Swift package set up, add the Git link within the `dependencies` value of your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/marcodotio/OpenAIKit.git", .upToNextMajor(from: "1.1.0"))
]
```

## Using OpenAIKit

OpenAIKit is designed to be very easy to integrate into your own projects. The main method of utilizing OpenAIKit is to set a `OpenAI` class object:

```swift
import OpenAIKit

// An API key and Organization ID is required to use the API library.
// Note: It's recommended to load the API Key through a .plist dictionary, rather than hard coding it in a String.
let config = Configuration(organization: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")

// Create an `OpenAI` object using the Configuration object.
let openAI = OpenAI(config)
```

From there, it's as easy as calling one of the provided function members. The code below demonstrates how you can generate an image using `createImage()`:

```swift
do {
    let imageParam = ImageParameters(
      prompt: "a red apple", 
      resolution: .small, 
      responseFormat: .base64Json
    )
    let result = try await openAi.createImage(
      parameters: imageParam
    )
    let b64Image = result.data[0].image
    let image = try openAi.decodeBase64Image(b64Image)
} catch {
    // Insert your own error handling method here.
}
```

As well, you are able to generate completions using GPT-3:

```swift
do {
    let completionParameter = CompletionParameters(
      model: "text-davinci-001", 
      prompt: ["Say this is a test ->"], 
      maxTokens: 4, 
      temperature: 0.98
    )
    let completionResponse = try await openAI.generateCompletion(
      parameters: completionParameter
    )
    let responseText = completionResponse.choices[0].text
} catch {
    // Insert your own error handling method here.
}
```

## Development And Testing

I welcome anyone to contribute to the project through posting issues, if they encounter any bugs / glitches while using OpenAIKit; and as well with creating pull issues that add any additional features to OpenAIKit.

## Next Steps

* In the near future, there will be full documentation outlining how a user can fully utilize OpenAIKit.
* As well, more features listed in [ToDo](#todo) will be fully implemented.
* More examples, from other platforms, will be uploaded for developers to be able to focus more on implementing the end user experience, and less time figuring out their project's architecture.

## Credits

I would like to personally thank the [OpenAI Team](https://openai.com) for implementing the REST endpoint and implementing the models themselves, as without them, this project wouldn't have been possible. 

As well, I would like to personally thank [YufeiG](https://github.com/YufeiG) for providing troubleshooting help on sending Image data for the Image Edit and Variations endpoints.

## License

OpenAIKit is released under the MIT license, and any use of OpenAI's REST endpoint will be under the [Usage policies](https://beta.openai.com/docs/usage-policies) set by them. [See LICENSE](https://github.com/MarcoDotIO/OpenAIKit/blob/main/LICENSE) for details.
