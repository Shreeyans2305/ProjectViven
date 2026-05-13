import SwiftUI

struct TypingDotsView: View {
    @State private var activeIndex = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(activeIndex == index ? 1.2 : 0.75)
                    .opacity(activeIndex == index ? 1 : 0.45)
                    .animation(.easeInOut(duration: 0.55), value: activeIndex)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: false)) {
                activeIndex = 2
            }
        }
        .accessibilityLabel("VIVEN is typing")
    }
}
