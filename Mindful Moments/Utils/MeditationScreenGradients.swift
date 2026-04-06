//
//  MeditationScreenGradients.swift
//  Mindful Moments
//
//  Canonical background gradients for meditation flows (detail, player, quick breathing).
//

import SwiftUI

enum MeditationScreenGradients {

    // MARK: - Quick Breathing
    /// Light: #00c0e8 → #a3e8f5
    private static let quickBreathingLightTop = Color(red: 0, green: 192 / 255, blue: 232 / 255)
    private static let quickBreathingLightBottom = Color(red: 163 / 255, green: 232 / 255, blue: 245 / 255)
    /// Dark: #004b5c → #00c0e8
    private static let quickBreathingDarkTop = Color(red: 0, green: 75 / 255, blue: 92 / 255)
    private static let quickBreathingDarkBottom = Color(red: 0, green: 192 / 255, blue: 232 / 255)

    // MARK: - Themes (light: top → bottom, dark: top → bottom)

    /// Calm light #00c8b3 → #99e6de
    private static let calmLightTop = Color(red: 0, green: 200 / 255, blue: 179 / 255)
    private static let calmLightBottom = Color(red: 153 / 255, green: 230 / 255, blue: 222 / 255)
    /// Calm dark #003e39 → #00c8b3
    private static let calmDarkTop = Color(red: 0, green: 62 / 255, blue: 57 / 255)
    private static let calmDarkBottom = Color(red: 0, green: 200 / 255, blue: 179 / 255)

    /// Sleep light #6155f5 → #a8a2f9
    private static let sleepLightTop = Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255)
    private static let sleepLightBottom = Color(red: 168 / 255, green: 162 / 255, blue: 249 / 255)
    /// Sleep dark #1f1a4e → #6155f5
    private static let sleepDarkTop = Color(red: 31 / 255, green: 26 / 255, blue: 78 / 255)
    private static let sleepDarkBottom = Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255)

    /// Focus light #0088ff → #99cfff
    private static let focusLightTop = Color(red: 0, green: 136 / 255, blue: 1)
    private static let focusLightBottom = Color(red: 153 / 255, green: 207 / 255, blue: 1)
    /// Focus dark #002c53 → #0088ff
    private static let focusDarkTop = Color(red: 0, green: 44 / 255, blue: 83 / 255)
    private static let focusDarkBottom = Color(red: 0, green: 136 / 255, blue: 1)

    /// Stress Relief light #ff2d55 → #ffb8c5
    private static let stressLightTop = Color(red: 1, green: 45 / 255, blue: 85 / 255)
    private static let stressLightBottom = Color(red: 1, green: 184 / 255, blue: 197 / 255)
    /// Stress Relief dark #550012 → #ff2d55
    private static let stressDarkTop = Color(red: 85 / 255, green: 0, blue: 18 / 255)
    private static let stressDarkBottom = Color(red: 1, green: 45 / 255, blue: 85 / 255)

    /// Energy light #ff8d28 → #ffd4ab
    private static let energyLightTop = Color(red: 1, green: 141 / 255, blue: 40 / 255)
    private static let energyLightBottom = Color(red: 1, green: 212 / 255, blue: 171 / 255)
    /// Energy dark #4e2200 → #ff8d28
    private static let energyDarkTop = Color(red: 78 / 255, green: 34 / 255, blue: 0)
    private static let energyDarkBottom = Color(red: 1, green: 141 / 255, blue: 40 / 255)

    /// Gratitude light #ffcc00 → #fff3c2 (second stop matches spec foot)
    private static let gratitudeLightTop = Color(red: 1, green: 204 / 255, blue: 0)
    private static let gratitudeLightBottom = Color(red: 1, green: 243 / 255, blue: 194 / 255)
    /// Gratitude dark #4d3e00 → #ffcc00
    private static let gratitudeDarkTop = Color(red: 77 / 255, green: 62 / 255, blue: 0)
    private static let gratitudeDarkBottom = Color(red: 1, green: 204 / 255, blue: 0)

    /// Colors for full-screen meditation backgrounds (detail + player).
    static func themeColors(themeName: String, isDark: Bool) -> [Color] {
        switch themeName {
        case "Calm":
            return isDark ? [calmDarkTop, calmDarkBottom] : [calmLightTop, calmLightBottom]
        case "Sleep":
            return isDark ? [sleepDarkTop, sleepDarkBottom] : [sleepLightTop, sleepLightBottom]
        case "Focus":
            return isDark ? [focusDarkTop, focusDarkBottom] : [focusLightTop, focusLightBottom]
        case "Stress Relief":
            return isDark ? [stressDarkTop, stressDarkBottom] : [stressLightTop, stressLightBottom]
        case "Energy":
            return isDark ? [energyDarkTop, energyDarkBottom] : [energyLightTop, energyLightBottom]
        case "Gratitude":
            return isDark ? [gratitudeDarkTop, gratitudeDarkBottom] : [gratitudeLightTop, gratitudeLightBottom]
        default:
            return isDark
                ? [Color(red: 0.10, green: 0.12, blue: 0.13), Color(red: 0.08, green: 0.10, blue: 0.09)]
                : [Color(red: 0.95, green: 0.97, blue: 0.98), Color(red: 0.93, green: 0.95, blue: 0.92)]
        }
    }

    static func quickBreathingColors(isDark: Bool) -> [Color] {
        isDark
            ? [quickBreathingDarkTop, quickBreathingDarkBottom]
            : [quickBreathingLightTop, quickBreathingLightBottom]
    }
}
