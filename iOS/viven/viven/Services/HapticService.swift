import CoreHaptics
import UIKit

final class HapticService {
    private var engine: CHHapticEngine?

    init() {
        prepareEngine()
    }

    func tap(intensity: Float = 0.6) {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            playCoreHaptic(intensity: intensity)
        } else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    private func playCoreHaptic(intensity: Float) {
        if engine == nil {
            prepareEngine()
        }

        guard let engine else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            return
        }

        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
