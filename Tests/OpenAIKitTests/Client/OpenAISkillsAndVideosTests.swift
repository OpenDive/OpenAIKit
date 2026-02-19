import XCTest
@testable import OpenAIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class OpenAISkillsAndVideosTests: XCTestCase {
    private func makeClient() -> OpenAI {
        OpenAI(.init(organizationId: "org_test", apiKey: "test_key"))
    }

    func testVideoCreateParametersEncodePrompt() throws {
        let params = VideoCreateParameters(model: "sora-1", prompt: "A fast river in spring")
        let data = try JSONEncoder().encode(params)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["model"] as? String, "sora-1")
        XCTAssertEqual(object["prompt"] as? String, "A fast river in spring")
    }

    func testSkillsAndVideosMethodsAreExposed() {
        let client = makeClient()

        let createSkill: (SkillCreateParameters) async throws -> SkillObject = client.skills.create
        let listSkills: () async throws -> SkillListResponse = client.skills.list
        let retrieveSkill: (String) async throws -> SkillObject = client.skills.retrieve
        let updateSkill: (String, SkillUpdateParameters) async throws -> SkillObject = client.skills.update
        let deleteSkill: (String) async throws -> DeleteObject = client.skills.delete

        let retrieveSkillContent: (String) async throws -> Data = client.skills.content.retrieve
        let updateSkillContent: (String, SkillContentUpdateParameters) async throws -> SkillObject = client.skills.content.update
        let listVersions: (String) async throws -> SkillVersionListResponse = client.skills.versions.list
        let retrieveVersion: (String, String) async throws -> SkillVersionObject = client.skills.versions.retrieve
        let retrieveVersionContent: (String, String) async throws -> Data = client.skills.versions.content.retrieve

        let createVideo: (VideoCreateParameters) async throws -> VideoObject = client.videos.create
        let listVideos: () async throws -> VideoListResponse = client.videos.list
        let retrieveVideo: (String) async throws -> VideoObject = client.videos.retrieve
        let cancelVideo: (String) async throws -> VideoObject = client.videos.cancel

        XCTAssertNotNil(createSkill)
        XCTAssertNotNil(listSkills)
        XCTAssertNotNil(retrieveSkill)
        XCTAssertNotNil(updateSkill)
        XCTAssertNotNil(deleteSkill)
        XCTAssertNotNil(retrieveSkillContent)
        XCTAssertNotNil(updateSkillContent)
        XCTAssertNotNil(listVersions)
        XCTAssertNotNil(retrieveVersion)
        XCTAssertNotNil(retrieveVersionContent)
        XCTAssertNotNil(createVideo)
        XCTAssertNotNil(listVideos)
        XCTAssertNotNil(retrieveVideo)
        XCTAssertNotNil(cancelVideo)
    }
}
