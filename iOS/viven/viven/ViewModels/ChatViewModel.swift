import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    var draft = ""
    var messages: [Message]
    var isSending = false
    var statusMessage = "READY"

    private let llmService: any LLMServiceProtocol
    private let haptics: HapticService

    init(
        llmService: any LLMServiceProtocol,
        haptics: HapticService
    ) {
        self.llmService = llmService
        self.haptics = haptics
        self.messages = [
            Message(
                role: .viven,
                content: "VIVEN online. Describe your situation.",
                response: nil,
                timestamp: Date()
            )
        ]
    }

    func send() async {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        let userMessage = Message(role: .user, content: trimmed, response: nil, timestamp: Date())
        messages.append(userMessage)
        draft = ""
        isSending = true
        statusMessage = "ANALYSING"

        do {
            let response = try await llmService.chat(messages: messages)
            let vivenMessage = Message(
                role: .viven,
                content: response.structuredDisplayText,
                response: response,
                timestamp: Date()
            )
            messages.append(vivenMessage)
            statusMessage = response.threatLevel.label
            haptics.tap()
        } catch {
            let fallback = MockResponses.chatResponses["default"]!
            messages.append(
                Message(
                    role: .viven,
                    content: fallback.structuredDisplayText,
                    response: fallback,
                    timestamp: Date()
                )
            )
            statusMessage = "FALLBACK"
        }

        isSending = false
    }

    func sendDraftIfNeeded() {
        Task { await send() }
    }
}
