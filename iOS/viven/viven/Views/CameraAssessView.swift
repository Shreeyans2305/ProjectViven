import SwiftUI
import AVFoundation
import UIKit

struct CameraAssessView: View {
    @State private var viewModel: CameraViewModel

    init(llmService: any LLMServiceProtocol, haptics: HapticService) {
        _viewModel = State(initialValue: CameraViewModel(llmService: llmService, haptics: haptics))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if viewModel.authorizationStatus == .authorized {
                    cameraContent(in: geometry.size)
                } else {
                    permissionView
                        .padding(.horizontal, 24)
                }
            }
            .task {
                await viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    @ViewBuilder
    private func cameraContent(in size: CGSize) -> some View {
        let panelHeight = max(280, min(size.height * 0.38, 390))

        ZStack(alignment: .bottom) {
            CameraPreviewView(session: viewModel.cameraService.session)
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.08), Color.black.opacity(0.3), Color.black.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(14)
                .overlay {
                    SiriGlowBorder(cornerRadius: 16, lineWidth: 2, opacity: 0.45, isProcessing: viewModel.isProcessing)
                        .padding(14)
                }

            VStack(spacing: 14) {
                topControls

                Spacer(minLength: 0)

                assessmentPanel(height: panelHeight)
            }
            .frame(maxWidth: 680)
            .padding(.horizontal, 22)
            .padding(.top, max(18, size.height * 0.03))
            .padding(.bottom, 18)
        }
    }

    private var topControls: some View {
        HStack(alignment: .center, spacing: 12) {
            StatusBadge(
                title: viewModel.statusMessage,
                color: statusColor
            )

            Spacer(minLength: 0)

            Button {
                Task { await viewModel.toggleCamera() }
            } label: {
                Image(systemName: "camera.rotate.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "191817"))
                    .frame(width: 52, height: 52)
                    .background(Color(hex: "EEEDE6"), in: Circle())
                    .overlay(Circle().strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1))
            }
            .accessibilityLabel("Switch camera")
        }
    }

    private func assessmentPanel(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ThreatLevelIndicator(level: viewModel.latestResponse?.threatLevel ?? .minimal)

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.displayedAssessmentText.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Awaiting camera analysis...")
                                    .font(.system(size: 15, weight: .regular, design: .default))
                                    .foregroundStyle(Color.white.opacity(0.65))
                                Text("Tap assess situation to generate a structured survival response.")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundStyle(Color.white.opacity(0.35))
                            }
                            .padding(.top, 4)
                        } else {
                            StructuredResponseTextView(text: viewModel.displayedAssessmentText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 6)
                    .padding(.bottom, 8)
                    .id("assessment-bottom")
                }
                .onChange(of: viewModel.displayedAssessmentText) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("assessment-bottom", anchor: .bottom)
                    }
                }
            }

            Button {
                Task { await viewModel.assessSituation() }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isProcessing {
                        Text("ANALYSING")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                        ProcessingDotsView()
                    } else {
                        Text("ASSESS SITUATION")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .tracking(1.1)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 29, style: .continuous)
                        .strokeBorder(Color(hex: "F5A623").opacity(0.8), lineWidth: 1)
                )
                .shadow(color: Color(hex: "F5A623").opacity(0.18), radius: 12, y: 4)
                .clipShape(RoundedRectangle(cornerRadius: 29, style: .continuous))
            }
            .disabled(viewModel.isProcessing)
            .accessibilityLabel(viewModel.isProcessing ? "Analysing situation" : "Assess situation")
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(hex: "F4F3EE").opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
        )
        .overlay {
            SiriGlowBorder(cornerRadius: 16, lineWidth: 2, opacity: 0.45, isProcessing: viewModel.isProcessing)
        }
        .background(Color(hex: "EEEDE6").opacity(0.85), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var permissionView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            Image(systemName: "camera.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color(hex: "F5A623"))
                .frame(width: 76, height: 76)
                .background(Color.white.opacity(0.05), in: Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

            VStack(spacing: 10) {
                Text(viewModel.authorizationStatus == .notDetermined ? "Camera Permission Required" : "Camera Access Denied")
                    .font(.system(size: 30, weight: .medium, design: .serif))
                    .tracking(-0.3)
                    .foregroundStyle(Color(hex: "191817"))
                    .multilineTextAlignment(.center)

                Text("VIVEN needs camera access to assess live scenes in real time. You can enable access in Settings or grant permission now.")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(Color(hex: "5A554E"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                Task { await viewModel.requestCameraAccess() }
            } label: {
                Text(viewModel.authorizationStatus == .notDetermined ? "ALLOW CAMERA" : "TRY AGAIN")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .tracking(0.3)
                    .foregroundStyle(Color(hex: "F4F3EE"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "C96442"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityLabel("Request camera access")

            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            } label: {
                Text("OPEN SETTINGS")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .tracking(0.6)
                    .foregroundStyle(Color(hex: "191817"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(hex: "F4F3EE"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Open app settings")

            Spacer(minLength: 20)
        }
        .padding(24)
        .background(Color(hex: "F4F3EE").opacity(0.96), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(hex: "D8D3C8"), lineWidth: 1)
        )
        .overlay {
            SiriGlowBorder(cornerRadius: 16, lineWidth: 2, opacity: 0.28, isProcessing: false)
        }
    }

    private var statusColor: Color {
        switch viewModel.statusMessage {
        case "ANALYSING":
            return Color(hex: "C98A42")
        case "LIVE CAMERA", "SIMULATOR PREVIEW":
            return Color(hex: "6B7A3D")
        case "CAMERA PERMISSION REQUIRED":
            return Color(hex: "C96442")
        case "CAMERA ACCESS DENIED", "CAMERA UNAVAILABLE", "ANALYSIS FAILED", "TOGGLE FAILED":
            return Color(hex: "A53E2A")
        default:
            return Color(hex: "5A554E")
        }
    }
}

private struct ProcessingDotsView: View {
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                ProcessingDot(delay: Double(index) * 0.15)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ProcessingDot: View {
    let delay: Double
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 5, height: 5)
            .scaleEffect(animate ? 1.2 : 0.65)
            .opacity(animate ? 1 : 0.4)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                        animate = true
                    }
                }
            }
    }
}
