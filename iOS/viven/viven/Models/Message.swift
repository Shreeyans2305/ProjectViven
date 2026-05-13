import Foundation

struct Message: Identifiable, Hashable, Sendable {
    enum Role: String, Hashable, Sendable {
        case user
        case viven
    }

    let id = UUID()
    let role: Role
    let content: String
    let response: VIVENResponse?
    let timestamp: Date

    var isUser: Bool { role == .user }
}
