import Foundation

protocol LLMServiceProtocol: AnyObject {
    func assess(prompt: String) async throws -> VIVENResponse
    func chat(messages: [Message]) async throws -> VIVENResponse
}

final class MockLLMService: LLMServiceProtocol {
    func assess(prompt: String) async throws -> VIVENResponse {
        try await Task.sleep(nanoseconds: 2_500_000_000)
        return MockResponses.cameraAssessments.randomElement() ?? MockResponses.chatResponses["default"]!
    }

    func chat(messages: [Message]) async throws -> VIVENResponse {
        try await Task.sleep(nanoseconds: 1_800_000_000)
        let lastMessage = messages.last?.content.lowercased() ?? ""
        return MockResponses.chatResponse(for: lastMessage)
    }
}

// Future drop-in replacement for local llama.cpp inference.
// final class LlamaCppLLMService: LLMServiceProtocol { ... }
