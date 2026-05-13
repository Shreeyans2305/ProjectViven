import SwiftUI

struct StatusBadge: View {
    let title: String
    var color: Color = .white

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(1.3)
                .foregroundStyle(Color(hex: "191817"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "EEEDE6"), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
