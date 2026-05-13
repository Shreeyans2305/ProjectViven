import Observation
import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    @FocusState private var isComposerFocused: Bool

    init(llmService: any LLMServiceProtocol, haptics: HapticService) {
        _viewModel = State(initialValue: ChatViewModel(llmService: llmService, haptics: haptics))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                background

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isSending {
                                typingIndicator
                                    .id("typing-indicator")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToLatest(using: proxy)
                    }
                    .onChange(of: viewModel.isSending) { _, _ in
                        scrollToLatest(using: proxy)
                    }
                    .task {
                        scrollToLatest(using: proxy)
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                header
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputBar(
                    draft: $viewModel.draft,
                    isSending: viewModel.isSending
                )
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(hex: "F4F3EE")
                .ignoresSafeArea()

            RadialGradient(colors: [Color(hex: "EEEDE6"), .clear], center: .top, startRadius: 0, endRadius: 560)
                .ignoresSafeArea()
                .blendMode(.multiply)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                PulsingOrb(color: Color(hex: "6B7A3D"), size: 7)

                VStack(alignment: .leading, spacing: 2) {
                    Text("VIVEN")
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .tracking(-0.35)
                        .foregroundStyle(Color(hex: "191817"))

                    Text("Calm, structured guidance for uncertain moments.")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundStyle(Color(hex: "5A554E"))
                }

                Spacer()
            }

            Rectangle()
                .fill(Color(hex: "D8D3C8"))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
        .background(Color(hex: "F4F3EE").opacity(0.96))
    }

    private var typingIndicator: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("VIVEN")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(Color(hex: "C96442"))

                HStack(spacing: 10) {
                    TypingDotsView()
                    Text("Drafting a response")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(Color(hex: "5A554E"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color(hex: "EEEDE6"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(Color(hex: "C96442"))
                    .frame(width: 3)
                    .padding(.vertical, 10)
                    .padding(.leading, 1)
            }

            Spacer(minLength: 44)
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
    }

    private func inputBar(draft: Binding<String>, isSending: Bool) -> some View {
        HStack(spacing: 12) {
            TextField("Describe your situation.", text: draft, axis: .vertical)
                .focused($isComposerFocused)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .foregroundStyle(Color(hex: "191817"))
                .submitLabel(.send)
                .onSubmit {
                    viewModel.sendDraftIfNeeded()
                }
                .accessibilityLabel("Situation description")

            Button {
                viewModel.sendDraftIfNeeded()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "F4F3EE"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "C96442"), in: Circle())
            }
            .disabled(draft.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .accessibilityLabel("Send message")
        }
        .padding(12)
        .background(
            Color(hex: "EEEDE6"),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
        )
        .overlay {
            SiriGlowBorder(cornerRadius: 12, lineWidth: 2, opacity: draft.wrappedValue.isEmpty ? 0.18 : 0.45, isProcessing: isSending)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.clear)
    }

    private func scrollToLatest(using proxy: ScrollViewProxy) {
        let target: AnyHashable? = viewModel.isSending ? "typing-indicator" : viewModel.messages.last?.id
        guard let target else { return }

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(target, anchor: .bottom)
            }
        }
    }
}
