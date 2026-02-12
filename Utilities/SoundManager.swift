import UIKit
import AVFoundation

@MainActor
class SoundManager {
    static let shared = SoundManager()

    private init() {}

    // Play success sound with haptic feedback
    func playSuccessSound() {
        guard SettingsManager.shared.playSounds else { return }

        // Play haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Play system sound (success sound)
        AudioServicesPlaySystemSound(1054) // System sound for success
    }

    // Play completion sound with haptic feedback
    func playCompletionSound() {
        guard SettingsManager.shared.playSounds else { return }

        // Play haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Play system sound (completion sound)
        AudioServicesPlaySystemSound(1057) // System sound for message sent
    }

    // Play light tap sound
    func playTapSound() {
        guard SettingsManager.shared.playSounds else { return }

        // Play light haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
