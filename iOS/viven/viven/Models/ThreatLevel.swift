import SwiftUI

enum ThreatLevel: Int, CaseIterable, Hashable, Sendable {
    case minimal = 0
    case low
    case moderate
    case high
    case critical

    var color: Color {
        switch self {
        case .minimal:
            return Color(hex: "4CAF50")
        case .low:
            return Color(hex: "8BC34A")
        case .moderate:
            return Color(hex: "F5A623")
        case .high:
            return Color(hex: "FF5722")
        case .critical:
            return Color(hex: "F44336")
        }
    }

    var label: String {
        switch self {
        case .minimal: return "MINIMAL"
        case .low: return "LOW"
        case .moderate: return "MODERATE"
        case .high: return "HIGH"
        case .critical: return "CRITICAL"
        }
    }

    var displayTitle: String {
        label
    }
}
