//
//  HapticManager.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import UIKit

/// Manager for haptic feedback throughout the app
enum HapticManager {
    
    /// Light impact feedback for subtle interactions
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact feedback for important interactions
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback for major interactions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Selection feedback for picker/toggle changes
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Success notification feedback
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification feedback
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification feedback
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
