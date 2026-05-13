import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable {
        case assess
        case chat
    }

    @State private var selection: Tab = .assess

    private let llmService: any LLMServiceProtocol
    private let haptics: HapticService

    init(llmService: any LLMServiceProtocol, haptics: HapticService) {
        self.llmService = llmService
        self.haptics = haptics
    }

    var body: some View {
        ZStack {
            switch selection {
            case .assess:
                CameraAssessView(llmService: llmService, haptics: haptics)
            case .chat:
                ChatView(llmService: llmService, haptics: haptics)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
        .preferredColorScheme(.dark)
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack {
                tabButton(
                    tab: .assess,
                    systemImage: "camera.viewfinder",
                    isSelected: selection == .assess,
                    accessibilityLabel: "Assess tab"
                )

                Spacer(minLength: 0)

                tabButton(
                    tab: .chat,
                    systemImage: "message.fill",
                    isSelected: selection == .chat,
                    accessibilityLabel: "Chat tab"
                )
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
        }
        .background(
            Color(hex: "F4F3EE")
        )
        .overlay(Rectangle().fill(Color(hex: "D8D3C8")).frame(height: 1), alignment: .top)
    }

    private func tabButton(tab: Tab, systemImage: String, isSelected: Bool, accessibilityLabel: String) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .semibold))
                Text(tab == .assess ? "Assess" : "Chat")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(0.4)
            }
            .foregroundStyle(isSelected ? Color(hex: "C96442") : Color(hex: "8A847A"))
            .frame(width: 84, height: 44)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(isSelected ? Color(hex: "C96442") : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal, 14)
                    .padding(.bottom, -2)
            }
            .contentShape(Rectangle())
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .frame(minWidth: 84, minHeight: 44)
    }
}
