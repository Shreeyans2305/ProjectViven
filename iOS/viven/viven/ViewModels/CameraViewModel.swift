import AVFoundation
import Foundation
import Observation

@MainActor
@Observable
final class CameraViewModel {
    var authorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    var isCameraAvailable = true
    var isProcessing = false
    var isStreamingResponse = false
    var latestResponse: VIVENResponse?
    var displayedAssessmentText = ""
    var statusMessage = "READY"
    var selectedPosition: AVCaptureDevice.Position = .back

    let cameraService: CameraService
    private let llmService: any LLMServiceProtocol
    private let haptics: HapticService
    private var typewriterTask: Task<Void, Never>?

    init(
        cameraService: CameraService? = nil,
        llmService: any LLMServiceProtocol,
        haptics: HapticService
    ) {
        self.cameraService = cameraService ?? CameraService()
        self.llmService = llmService
        self.haptics = haptics
    }

    func onAppear() async {
        refreshAuthorizationStatus()

        guard authorizationStatus == .authorized else {
            statusMessage = authorizationStatus == .notDetermined ? "CAMERA PERMISSION REQUIRED" : "CAMERA ACCESS DENIED"
            return
        }

        do {
            isCameraAvailable = try await cameraService.configure(position: selectedPosition)
            cameraService.start()
            statusMessage = isCameraAvailable ? "LIVE CAMERA" : "SIMULATOR PREVIEW"
        } catch {
            isCameraAvailable = false
            statusMessage = "CAMERA UNAVAILABLE"
        }
    }

    func onDisappear() {
        cameraService.stop()
        typewriterTask?.cancel()
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestCameraAccess() async {
        let granted = await cameraService.requestAccess()
        refreshAuthorizationStatus()

        guard granted else {
            statusMessage = "CAMERA ACCESS DENIED"
            return
        }

        await onAppear()
    }

    func toggleCamera() async {
        guard authorizationStatus == .authorized else { return }

        do {
            selectedPosition = selectedPosition == .back ? .front : .back
            isCameraAvailable = try await cameraService.toggleCamera()
            cameraService.start()
            statusMessage = isCameraAvailable ? "LIVE CAMERA" : "SIMULATOR PREVIEW"
        } catch {
            statusMessage = "TOGGLE FAILED"
        }
    }

    func assessSituation() async {
        guard !isProcessing else { return }

        typewriterTask?.cancel()
        isProcessing = true
        isStreamingResponse = false
        displayedAssessmentText = ""
        statusMessage = "ANALYSING"

        do {
            let response = try await llmService.assess(prompt: "Assess the live camera scene for immediate survival risks and response steps.")
            latestResponse = response
            statusMessage = response.threatLevel.label
            isProcessing = false
            await stream(response.structuredDisplayText)
        } catch {
            isProcessing = false
            statusMessage = "ANALYSIS FAILED"
            displayedAssessmentText = "[ASSESS] Unable to complete assessment.\n[PRIORITY] Retry or switch to chat.\n[STEPS] Check permissions, camera access, and connection state.\n[WATCH FOR] Persistent errors or missing input devices."
        }
    }

    private func stream(_ text: String) async {
        isStreamingResponse = true
        displayedAssessmentText = ""

        for character in text {
            if Task.isCancelled { return }
            displayedAssessmentText.append(character)
            try? await Task.sleep(nanoseconds: 18_000_000)
        }

        isStreamingResponse = false
        haptics.tap()
    }
}
