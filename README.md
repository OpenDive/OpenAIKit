[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS-green?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS-green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Swift](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml)

<div align="center">
  <a href="https://github.com/MarcoDotIO/OpenAIKit">
     <img src="Resources/Logo.png" alt="OpenAIKit Logo" width="80" height="80">
 </a>
 <h3 align="center">OpenAIKit</h3>
  <p align="center">
  A community-maintained Swift API for the OpenAI REST endpoint.
  <br />
     <a href="https://github.com/MarcoDotIO/OpenAIKit/wiki"><strong>Explore the docs »</strong></a>
  <br />
  <br />
     <a href="https://github.com/MarcoDotIO/OpenAIKit/issues">Report Bug</a>
  ·
     <a href="https://github.com/MarcoDotIO/OpenAIKit/issues">Request Feature</a>
 </p>
</div>


## Table of Contents

- [About the Project][#about-the-project]

  - [Motivation](#motivation)
  - [Our Vision](#our-vision)
- [Features](#features)
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

## About the Project

(Insert Screenshot from visionOS template project)

**OpenAIKit** is a community-driven Swift SDK designed to provide Swift developers with a seamless, efficient, and Swifty way to interact with the OpenAI REST endpoint. Our aim is to lower the barrier for Swift developers, enabling them to integrate the power of OpenAI into their apps without delving deep into the intricacies of RESTful services.

### Motivation

With the increasing demand for AI-powered features in modern applications, it's crucial for developers to have access to tools that simplify the integration process. While OpenAI offers an incredible suite of capabilities, there was a clear need for a dedicated Swift SDK that aligns with the idiomatic practices of the language and the expectations of the Swift developer community.

### Our Vision

As the lead developer for OpenAIKit, I envisioned a tool that not only provides raw access to OpenAI functionalities but also enhances the developer experience with a clear and intuitive API. Our ultimate goal is to foster innovation by providing the Swift community with the right tools to integrate AI capabilities into their applications effortlessly.

## Features

- [x] Generate new, edited, and variations of images using Dall-E 2 (Dall-E 3 coming soon).
- [x] Generate edits and completions using GPT-3 and GPT-4.
- [x] List avaiable models for use with GPT-3 and GPT-4.
- [x] Retrieve embeddings for GPT-3 and GPT-4 prompts.
- [x] Stream data for GPT-3 and GPT-4 completions.
- [x] Generate Chat responses using ChatGPT.
- [x] View and Upload training files.
- [x] View whether a prompt is flagged by the Moderations endpoint or not.
- [x] Comprehensive Unit and Integration Test coverage.
- [x] Swift Concurrency compatibility back to iOS 13, macOS 10.15, tvOS 13, watchOS 6, and visionOS 1.0.
- [x] Complete documentation of OpenAIKit.

## Requirements

| Platform                                                     | Minimum Swift Version | Installation                                    | Status       |
| ------------------------------------------------------------ | --------------------- | ----------------------------------------------- | ------------ |
| iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+ | 5.5                   | [Swift Package Manager](#swift-package-manager) | Fully Tested |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) allows for developers to easily integrate packages into their Xcode projects and packages; and is also fully integrated into the `swift` compiler.

#### SPM Through XCode Project

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/marcodotio/OpenAIKit.git`
* Select "Up to next Major" with "1.2"

#### SPM Through Xcode Package

Once you have your Swift package set up, add the Git link within the `dependencies` value of your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/marcodotio/OpenAIKit.git", .upToNextMajor(from: "1.2"))
]
```

## Using OpenAIKit

OpenAIKit is designed to be very easy to integrate into your own projects. The main method of utilizing OpenAIKit is to set a `OpenAI` class object:

```swift
import OpenAIKit

// An API key and Organization ID is required to use the API library.
let config = Configuration(organizationId: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")

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

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/MarcoDotIO/OpenAIKit/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/MarcoDotIO/OpenAIKit/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/MarcoDotIO/OpenAIKit/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/MarcoDotIO/OpenAIKit/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/MarcoDotIO/OpenAIKit/blob/main/LICENSE.txt

[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5_5.6_5.7-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS-green?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS-green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Swift](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/MarcoDotIO/OpenAIKit/actions/workflows/swift.yml)

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
- [x] Generate Chat responses using ChatGPT.
- [x] Upload and view training set files for Fine-tuning.
- [x] Generate and use Fine-tuned models.
- [x] View whether a prompt is flagged by the Moderations endpoint or not.
- [x] Comprehensive Unit and Integration Test coverage.
- [x] Swift Concurrency Support back to iOS 13, macOS 10.15, tvOS 13, and watchOS 6.
- [x] Complete documentation of OpenAIKit.

## ToDo

- [ ] Implement data streaming for Fine-Tune and GPT-3 event streams.

## Requirements

| Platform                                                     | Minimum Swift Version | Installation                                    | Status       |
| ------------------------------------------------------------ | --------------------- | ----------------------------------------------- | ------------ |
| iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+ | 5.5                   | [Swift Package Manager](#swift-package-manager) | Fully Tested |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) allows for developers to easily integrate packages into their Xcode projects and packages; and is also fully integrated into the `swift` compiler.

#### SPM Through XCode Project

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/marcodotio/OpenAIKit.git`
* Select "Up to next Major" with "1.2"

#### SPM Through Xcode Package

Once you have your Swift package set up, add the Git link within the `dependencies` value of your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/marcodotio/OpenAIKit.git", .upToNextMajor(from: "1.2"))
]
```

## Using OpenAIKit

OpenAIKit is designed to be very easy to integrate into your own projects. The main method of utilizing OpenAIKit is to set a `OpenAI` class object:

```swift
import OpenAIKit

// An API key and Organization ID is required to use the API library.
// Note: It's recommended to load the API Key through a .plist dictionary, rather than hard coding it in a String.
let config = Configuration(organizationId: "INSERT-ORGANIZATION-ID", apiKey: "INSERT-API-KEY")

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

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/MarcoDotIO/OpenAIKit/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/MarcoDotIO/OpenAIKit/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/MarcoDotIO/OpenAIKit/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/MarcoDotIO/OpenAIKit/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/MarcoDotIO/OpenAIKit/blob/main/LICENSE.txt
