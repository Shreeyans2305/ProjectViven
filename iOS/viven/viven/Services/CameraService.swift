import Foundation
@preconcurrency import AVFoundation

final class CameraService: NSObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.projectviven.camera.session")
    private var currentInput: AVCaptureDeviceInput?
    private(set) var currentPosition: AVCaptureDevice.Position = .back

    func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func configure(position: AVCaptureDevice.Position) async throws -> Bool {
        currentPosition = position
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [session] in
                session.beginConfiguration()
                session.sessionPreset = .high

                if let currentInput = self.currentInput {
                    session.removeInput(currentInput)
                    self.currentInput = nil
                }

                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                      let input = try? AVCaptureDeviceInput(device: device),
                      session.canAddInput(input) else {
                    session.commitConfiguration()
                    continuation.resume(returning: false)
                    return
                }

                session.addInput(input)
                self.currentInput = input
                session.commitConfiguration()
                continuation.resume(returning: true)
            }
        }
    }

    func toggleCamera() async throws -> Bool {
        let nextPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        return try await configure(position: nextPosition)
    }

    func start() {
        sessionQueue.async { [session] in
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }
}
