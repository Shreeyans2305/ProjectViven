import SwiftUI

struct ThreatLevelIndicator: View {
    let level: ThreatLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach(ThreatLevel.allCases, id: \.self) { candidate in
                    let isActive = candidate.rawValue <= level.rawValue
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isActive ? candidate.color : Color.white.opacity(0.08))
                        .frame(height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: level)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 8) {
                ForEach(ThreatLevel.allCases, id: \.self) { candidate in
                    Text(candidate.label)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundStyle(candidate == level ? Color(hex: "191817") : Color(hex: "8A847A"))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Threat level \(level.label)")
    }
}
