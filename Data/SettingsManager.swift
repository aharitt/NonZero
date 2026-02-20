import Foundation
import SwiftUI

@MainActor
@Observable
class SettingsManager {
    static let shared = SettingsManager()

    // Settings stored in UserDefaults via AppStorage
    var showBadge: Bool {
        didSet {
            UserDefaults.standard.set(showBadge, forKey: "showBadge")
            if showBadge {
                NotificationCenter.default.post(name: .refreshBadge, object: nil)
            } else {
                AppBadgeManager.shared.clearBadge()
            }
        }
    }

    var playSounds: Bool {
        didSet {
            UserDefaults.standard.set(playSounds, forKey: "playSounds")
        }
    }

    var dayScoreCriteria: Int {
        didSet {
            UserDefaults.standard.set(dayScoreCriteria, forKey: "dayScoreCriteria")
        }
    }

    private init() {
        // Load settings from UserDefaults
        self.showBadge = UserDefaults.standard.object(forKey: "showBadge") as? Bool ?? true
        self.playSounds = UserDefaults.standard.object(forKey: "playSounds") as? Bool ?? true
        self.dayScoreCriteria = UserDefaults.standard.object(forKey: "dayScoreCriteria") as? Int ?? 10
    }
}
