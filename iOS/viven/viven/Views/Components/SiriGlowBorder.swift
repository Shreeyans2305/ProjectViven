import SwiftUI

struct SiriGlowBorder: View {
    let cornerRadius: CGFloat
    var lineWidth: CGFloat = 3
    var opacity: Double = 1
    var isProcessing: Bool = false

    @State private var rotation: Double = 0
    @State private var animationToken = UUID()

    private let gradientColors: [Color] = [
        Color(hex: "F4F3EE"),
        Color(hex: "E89268"),
        Color(hex: "C96442"),
        Color(hex: "D8D3C8"),
        Color(hex: "F4F3EE")
    ]

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(colors: gradientColors),
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: lineWidth
            )
            .shadow(color: Color(hex: "C96442").opacity(0.18 * opacity), radius: 5)
            .opacity(opacity)
            .id(animationToken)
            .allowsHitTesting(false)
            .onAppear(perform: restart)
            .onChange(of: isProcessing) { _, _ in
                restart()
            }
    }

    private func restart() {
        animationToken = UUID()
        rotation = 0
        let duration = isProcessing ? 1.2 : 3.0
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}
