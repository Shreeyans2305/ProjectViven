import SwiftUI
import UIKit

struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser {
                Spacer(minLength: 44)
                userBubble
            } else {
                vivenAccent
                vivenBubble
                Spacer(minLength: 44)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
    }

    private var userBubble: some View {
        Text(message.content)
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundStyle(Color(hex: "F4F3EE"))
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color(hex: "C96442"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .clipShape(UserBubbleShape())
            .frame(maxWidth: 320, alignment: .trailing)
            .accessibilityLabel("You said: \(message.content)")
    }

    private var vivenBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VIVEN")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.8)
                .foregroundStyle(Color(hex: "C96442"))

            Group {
                if message.response != nil {
                    StructuredResponseTextView(text: message.content)
                } else {
                    Text(message.content)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(Color(hex: "191817"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: 340, alignment: .leading)
        .background(Color(hex: "EEEDE6"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(Color(hex: "C96442"))
                .frame(width: 3)
                .padding(.vertical, 10)
                .padding(.leading, 1)
        }
        .accessibilityLabel("VIVEN response: \(message.content)")
    }

    private var vivenAccent: some View {
        Color.clear.frame(width: 6)
    }
}

private struct UserBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft],
            cornerRadii: CGSize(width: 12, height: 12)
        )
        let tailRect = CGRect(x: rect.maxX - 12, y: rect.maxY - 12, width: 12, height: 12)
        path.append(UIBezierPath(roundedRect: tailRect, byRoundingCorners: [.bottomRight], cornerRadii: CGSize(width: 4, height: 4)))
        return Path(path.cgPath)
    }
}
