//
//  ReviewPromptManager.swift
//  Mindful Moments
//

import StoreKit
import UIKit

/// Tracks completed activities and requests an App Store review after the third one.
enum ReviewPromptManager {
    private static let completedCountKey = "reviewPromptCompletedActivityCount"
    private static let hasPromptedKey = "reviewPromptShownAtThirdActivity"
    private static let milestone = 3

    /// Call when the user successfully completes a meditation or full quick breathing session.
    static func recordCompletedActivity() {
        let count = UserDefaults.standard.integer(forKey: completedCountKey) + 1
        UserDefaults.standard.set(count, forKey: completedCountKey)
    }

    /// Presents the system review prompt after navigation has settled (e.g. back on the home screen).
    /// - Parameter afterDelay: Wait so sheets/alerts can dismiss before the prompt appears.
    static func requestReviewIfEligible(afterDelay: TimeInterval = 1.0) {
        let count = UserDefaults.standard.integer(forKey: completedCountKey)
        guard count >= milestone,
              !UserDefaults.standard.bool(forKey: hasPromptedKey) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + afterDelay) {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) else { return }

            UserDefaults.standard.set(true, forKey: hasPromptedKey)
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
