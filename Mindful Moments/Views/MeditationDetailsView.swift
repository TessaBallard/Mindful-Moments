//
//  MeditationDetailsView.swift
//  Mindful Moments
//
//  Meditation theme details and duration selection
//

import SwiftUI

struct MeditationDetailsView: View {
    let theme: MeditationTheme
    let sessionStore: SessionStore
    let journalStore: JournalStore
    let achievementsManager: AchievementsManager
    let backgroundSoundManager: BackgroundSoundManager
    
    @State private var selectedDuration = 5
    @State private var showingMoodCheckIn = false
    @State private var navigateToPlayer = false
    @State private var selectedMoodBefore: Mood? = nil
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    /// Calm light-mode accent (matches classic teal cards / CTA).
    private static let calmAccentTeal = Color(red: 26 / 255, green: 188 / 255, blue: 156 / 255)
    /// Focus accent #0088ff
    private static let focusAccentBlue = Color(red: 0, green: 136 / 255, blue: 1)
    private static let focusSecondaryTextDark = Color(red: 161 / 255, green: 182 / 255, blue: 209 / 255)
    /// Stress Relief accent #ff2d55, light gradient foot #ffb8c5
    private static let stressAccentPink = Color(red: 255 / 255, green: 45 / 255, blue: 85 / 255)
    private static let stressGradientLightBottom = Color(red: 255 / 255, green: 184 / 255, blue: 197 / 255)
    private static let stressDarkMaroonTop = Color(red: 85 / 255, green: 0, blue: 18 / 255) // #550012
    /// Energy accent #ff8d28, light gradient foot #ffd4ab
    private static let energyAccentOrange = Color(red: 255 / 255, green: 141 / 255, blue: 40 / 255)
    private static let energyGradientLightBottom = Color(red: 255 / 255, green: 212 / 255, blue: 171 / 255)
    private static let energyDarkBrownTop = Color(red: 78 / 255, green: 34 / 255, blue: 0) // #4e2200
    /// Gratitude gold #ffcc00, light gradient foot #fff3c2
    private static let gratitudeGold = Color(red: 255 / 255, green: 204 / 255, blue: 0)
    private static let gratitudeGradientLightBottom = Color(red: 255 / 255, green: 243 / 255, blue: 194 / 255)
    private var gradientColors: [Color] {
        MeditationScreenGradients.themeColors(themeName: theme.name, isDark: colorScheme == .dark)
    }
    
    private var isCalmLightReference: Bool {
        theme.name == "Calm" && colorScheme == .light
    }
    
    private var isSleepLightReference: Bool {
        theme.name == "Sleep" && colorScheme == .light
    }
    
    private var isSleepDarkReference: Bool {
        theme.name == "Sleep" && colorScheme == .dark
    }
    
    private var isFocusLightReference: Bool {
        theme.name == "Focus" && colorScheme == .light
    }
    
    private var isFocusDarkReference: Bool {
        theme.name == "Focus" && colorScheme == .dark
    }
    
    private var isStressReliefLightReference: Bool {
        theme.name == "Stress Relief" && colorScheme == .light
    }
    
    private var isStressReliefDarkReference: Bool {
        theme.name == "Stress Relief" && colorScheme == .dark
    }
    
    private var isEnergyLightReference: Bool {
        theme.name == "Energy" && colorScheme == .light
    }
    
    private var isEnergyDarkReference: Bool {
        theme.name == "Energy" && colorScheme == .dark
    }
    
    private var isGratitudeLightReference: Bool {
        theme.name == "Gratitude" && colorScheme == .light
    }
    
    private var isGratitudeDarkReference: Bool {
        theme.name == "Gratitude" && colorScheme == .dark
    }
    
    private var headerIconCircleFill: Color {
        if isCalmLightReference {
            return Color(red: 0.18, green: 0.72, blue: 0.65)
        }
        if isSleepDarkReference {
            return Color.white.opacity(0.14)
        }
        if isSleepLightReference {
            return Color.white.opacity(0.38)
        }
        if isFocusDarkReference {
            return Color.white.opacity(0.12)
        }
        if isFocusLightReference {
            return Color.white.opacity(0.42)
        }
        if isStressReliefDarkReference {
            return Color(red: 0.42, green: 0.14, blue: 0.22)
        }
        if isStressReliefLightReference {
            return Color.white.opacity(0.42)
        }
        if isEnergyDarkReference {
            return Color.white.opacity(0.14)
        }
        if isEnergyLightReference {
            return Color.white.opacity(0.42)
        }
        if isGratitudeDarkReference {
            return Color.white.opacity(0.14)
        }
        if isGratitudeLightReference {
            return Color.white.opacity(0.42)
        }
        return iconColor.opacity(colorScheme == .dark ? 0.2 : 0.15)
    }
    
    private var headerIconGlyphColor: Color {
        if isCalmLightReference {
            return Color(red: 0.0, green: 0.38, blue: 0.34)
        }
        if isSleepDarkReference {
            return Color(red: 0.72, green: 0.70, blue: 0.98)
        }
        if isSleepLightReference {
            return Color(red: 0.42, green: 0.36, blue: 0.88)
        }
        if isFocusDarkReference {
            return Self.focusAccentBlue
        }
        if isFocusLightReference {
            return Color(red: 0, green: 0.38, blue: 0.82)
        }
        if isStressReliefDarkReference {
            return Self.stressAccentPink
        }
        if isStressReliefLightReference {
            return Color(red: 0.72, green: 0.08, blue: 0.28)
        }
        if isEnergyDarkReference {
            return Self.energyAccentOrange
        }
        if isEnergyLightReference {
            return Color(red: 0.62, green: 0.28, blue: 0.02)
        }
        if isGratitudeDarkReference || isGratitudeLightReference {
            return Self.gratitudeGold
        }
        return iconColor
    }
    
    private var detailTitleColor: Color {
        if isCalmLightReference { return Color(red: 0.05, green: 0.12, blue: 0.11) }
        if isSleepDarkReference { return .white }
        if isSleepLightReference { return Color(red: 0.18, green: 0.14, blue: 0.42) }
        if isFocusDarkReference { return .white }
        if isFocusLightReference { return Color(red: 0.06, green: 0.22, blue: 0.42) }
        if isStressReliefDarkReference { return .white }
        if isStressReliefLightReference { return Color(red: 0.28, green: 0.04, blue: 0.12) }
        if isEnergyDarkReference { return .white }
        if isEnergyLightReference { return Color(red: 0.32, green: 0.14, blue: 0.02) }
        if isGratitudeDarkReference { return .white }
        if isGratitudeLightReference { return Color(red: 0.28, green: 0.20, blue: 0.02) }
        return Color.primary
    }
    
    /// Subtitle under theme title (not expectation rows).
    private var detailSubtitleColor: Color {
        if isCalmLightReference { return Color(red: 0.25, green: 0.42, blue: 0.40) }
        if isSleepDarkReference { return Color.white.opacity(0.88) }
        if isSleepLightReference { return Color(red: 0.30, green: 0.26, blue: 0.52).opacity(0.92) }
        if isFocusDarkReference { return Self.focusSecondaryTextDark }
        if isFocusLightReference { return Color(red: 0.12, green: 0.32, blue: 0.52).opacity(0.88) }
        if isStressReliefDarkReference { return Color.white.opacity(0.78) }
        if isStressReliefLightReference { return Color(red: 0.48, green: 0.14, blue: 0.26).opacity(0.88) }
        if isEnergyDarkReference { return Color.white.opacity(0.78) }
        if isEnergyLightReference { return Color(red: 0.50, green: 0.22, blue: 0.08).opacity(0.9) }
        if isGratitudeDarkReference { return Color.white.opacity(0.78) }
        if isGratitudeLightReference { return Color(red: 0.42, green: 0.32, blue: 0.08).opacity(0.9) }
        return Color.secondary
    }
    
    /// Tint for “What to Expect” rows.
    private var expectationRowTint: Color {
        if isSleepDarkReference { return Color(red: 0.78, green: 0.80, blue: 0.96) }
        if isSleepLightReference { return Color(red: 0.32, green: 0.28, blue: 0.55) }
        if isFocusDarkReference { return Self.focusSecondaryTextDark }
        if isFocusLightReference { return Color(red: 0.14, green: 0.30, blue: 0.48) }
        if isStressReliefDarkReference { return Color.white.opacity(0.82) }
        if isStressReliefLightReference { return Color(red: 0.38, green: 0.12, blue: 0.24) }
        if isEnergyDarkReference { return Color.white.opacity(0.82) }
        if isEnergyLightReference { return Color(red: 0.42, green: 0.20, blue: 0.08) }
        if isGratitudeDarkReference { return Color.white.opacity(0.82) }
        if isGratitudeLightReference { return Color(red: 0.38, green: 0.28, blue: 0.06) }
        return detailSubtitleColor
    }
    
    private var chooseDurationLabelColor: Color {
        if isCalmLightReference { return Color(red: 0.0, green: 0.36, blue: 0.32) }
        if isSleepDarkReference { return .white }
        if isSleepLightReference { return Color(red: 0.20, green: 0.16, blue: 0.45) }
        if isFocusDarkReference { return Self.focusSecondaryTextDark }
        if isFocusLightReference { return Color(red: 0.08, green: 0.24, blue: 0.44) }
        if isStressReliefDarkReference { return Color.white.opacity(0.72) }
        if isStressReliefLightReference { return Color(red: 0.22, green: 0.06, blue: 0.14) }
        if isEnergyDarkReference { return Color.white.opacity(0.72) }
        if isEnergyLightReference { return Color(red: 0.28, green: 0.12, blue: 0.04) }
        if isGratitudeDarkReference { return Color.white.opacity(0.72) }
        if isGratitudeLightReference { return Color(red: 0.32, green: 0.22, blue: 0.04) }
        return Color.primary
    }
    
    private var startButtonShadowColor: Color {
        if isSleepDarkReference { return Color(red: 0.52, green: 0.66, blue: 1.0).opacity(0.45) }
        if isSleepLightReference { return Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255).opacity(0.42) }
        if isCalmLightReference { return Self.calmAccentTeal.opacity(0.35) }
        if isFocusDarkReference || isFocusLightReference { return Self.focusAccentBlue.opacity(0.42) }
        if isStressReliefDarkReference || isStressReliefLightReference { return Self.stressAccentPink.opacity(0.42) }
        if isEnergyDarkReference || isEnergyLightReference { return Self.energyAccentOrange.opacity(0.42) }
        if isGratitudeDarkReference || isGratitudeLightReference { return Self.gratitudeGold.opacity(0.42) }
        return iconColor.opacity(0.35)
    }
    
    private var whatToExpectItems: [(icon: String, text: String)] {
        switch theme.name {
        case "Calm":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        case "Sleep":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        case "Focus":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        case "Stress Relief":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        case "Energy":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        case "Gratitude":
            return [
                ("sparkles", "Guided meditation with soothing voice"),
                ("waveform", "Calming background sounds"),
                ("heart.circle", "Peaceful and centered feeling")
            ]
        default:
            return Array(theme.benefits.prefix(3)).map { ("checkmark.circle.fill", $0) }
        }
    }
    
    private var detailScreenTitleFont: Font {
        if isCalmLightReference {
            return Font.system(size: 34, weight: .regular, design: .rounded)
        }
        if isEnergyDarkReference || isEnergyLightReference {
            return .system(size: 34, weight: .bold, design: .rounded)
        }
        if isSleepDarkReference || isSleepLightReference || isFocusDarkReference || isFocusLightReference
            || isStressReliefDarkReference || isStressReliefLightReference
            || isGratitudeDarkReference || isGratitudeLightReference {
            return .system(size: 34, weight: .regular, design: .rounded)
        }
        return .brandLargeTitle
    }
    
    private var toolbarBackButtonFill: Color {
        if isCalmLightReference { return Color(red: 0.16, green: 0.62, blue: 0.56) }
        if isSleepDarkReference { return Color.black.opacity(0.42) }
        if isSleepLightReference { return Color.black.opacity(0.28) }
        if isFocusDarkReference { return Color.black.opacity(0.38) }
        if isFocusLightReference { return Color.black.opacity(0.26) }
        if isStressReliefDarkReference { return Color(red: 0.42, green: 0.06, blue: 0.14).opacity(0.72) }
        if isStressReliefLightReference { return Color.black.opacity(0.26) }
        if isEnergyDarkReference { return Color(red: 0.18, green: 0.08, blue: 0.02).opacity(0.72) }
        if isEnergyLightReference { return Color.black.opacity(0.26) }
        if isGratitudeDarkReference { return Color(red: 0.22, green: 0.16, blue: 0.04).opacity(0.72) }
        if isGratitudeLightReference { return Color.black.opacity(0.26) }
        return iconColor.opacity(0.85)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Image(systemName: theme.iconName)
                        .font(.system(size: 56, weight: .regular, design: .rounded))
                        .foregroundStyle(headerIconGlyphColor)
                        .frame(width: 112, height: 112)
                        .background(Circle().fill(headerIconCircleFill))
                    
                    Text(theme.name)
                        .font(detailScreenTitleFont)
                        .foregroundStyle(detailTitleColor)
                    
                    Text(theme.description)
                        .font(.brandSubheadline)
                        .foregroundStyle(detailSubtitleColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                .padding(.top, 8)
                
                VStack(spacing: 14) {
                    Text("Choose Duration")
                        .font(.brandTitle3)
                        .foregroundStyle(chooseDurationLabelColor)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 12) {
                        ForEach(theme.availableDurations, id: \.self) { duration in
                            DurationButton(
                                duration: duration,
                                isSelected: selectedDuration == duration,
                                themeName: theme.name,
                                colorScheme: colorScheme,
                                action: {
                                    HapticManager.selection()
                                    selectedDuration = duration
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("What to Expect")
                        .font(.brandHeadline)
                        .fontWeight((isSleepDarkReference || isFocusDarkReference || isStressReliefDarkReference || isEnergyDarkReference || isGratitudeDarkReference) ? .bold : .semibold)
                        .foregroundStyle(detailTitleColor)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(whatToExpectItems.enumerated()), id: \.offset) { _, item in
                            ExpectationRow(icon: item.icon, text: item.text, tint: expectationRowTint)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Button(action: {
                    HapticManager.medium()
                    showingMoodCheckIn = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        
                        Text("Start Session")
                            .font(.brandHeadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        Group {
                            if isSleepDarkReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.44, green: 0.60, blue: 0.99),
                                                Color(red: 0.58, green: 0.72, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            } else if isSleepLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255),
                                                Color(red: 130 / 255, green: 115 / 255, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            } else if isCalmLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Self.calmAccentTeal)
                            } else if isFocusDarkReference || isFocusLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Self.focusAccentBlue)
                            } else if isStressReliefDarkReference || isStressReliefLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Self.stressAccentPink)
                            } else if isEnergyDarkReference || isEnergyLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Self.energyAccentOrange)
                            } else if isGratitudeDarkReference || isGratitudeLightReference {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Self.gratitudeGold)
                            } else {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(iconColor)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: startButtonShadowColor, radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticManager.selection()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(toolbarBackButtonFill)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }
        }
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .fullScreenCover(isPresented: $showingMoodCheckIn) {
            NavigationStack {
                MoodCheckInView(
                    timing: .before,
                    onMoodSelected: { mood in
                        selectedMoodBefore = mood
                        showingMoodCheckIn = false
                        navigateToPlayer = true
                    },
                    onSkip: {
                        selectedMoodBefore = nil
                        showingMoodCheckIn = false
                        navigateToPlayer = true
                    }
                )
            }
        }
        .navigationDestination(isPresented: $navigateToPlayer) {
            MeditationPlayerView(
                theme: theme,
                duration: selectedDuration,
                sessionStore: sessionStore,
                journalStore: journalStore,
                moodBefore: selectedMoodBefore,
                achievementsManager: achievementsManager,
                backgroundSoundManager: backgroundSoundManager
            )
        }
    }
    
    private var iconColor: Color {
        switch theme.color {
        case "mint": return colorScheme == .dark ? Color(red: 0.400, green: 0.900, blue: 0.850) : Color(red: 0.000, green: 0.784, blue: 0.702)
        case "indigo": return colorScheme == .dark ? Color(red: 0.600, green: 0.550, blue: 1.000) : Color(red: 0.380, green: 0.333, blue: 0.961)
        case "blue": return colorScheme == .dark ? Color(red: 0.400, green: 0.750, blue: 1.000) : Color(red: 0.000, green: 0.533, blue: 1.000)
        case "pink": return .pink
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .primary
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let themeName: String
    let colorScheme: ColorScheme
    let action: () -> Void
    
    private var calmLightClassic: Bool {
        themeName == "Calm" && colorScheme == .light
    }
    
    private var calmDarkClassic: Bool {
        themeName == "Calm" && colorScheme == .dark
    }
    
    private var sleepLightClassic: Bool {
        themeName == "Sleep" && colorScheme == .light
    }
    
    private var sleepDarkClassic: Bool {
        themeName == "Sleep" && colorScheme == .dark
    }
    
    private var focusLightClassic: Bool {
        themeName == "Focus" && colorScheme == .light
    }
    
    private var focusDarkClassic: Bool {
        themeName == "Focus" && colorScheme == .dark
    }
    
    private var stressLightClassic: Bool {
        themeName == "Stress Relief" && colorScheme == .light
    }
    
    private var stressDarkClassic: Bool {
        themeName == "Stress Relief" && colorScheme == .dark
    }
    
    private var energyLightClassic: Bool {
        themeName == "Energy" && colorScheme == .light
    }
    
    private var energyDarkClassic: Bool {
        themeName == "Energy" && colorScheme == .dark
    }
    
    private var gratitudeLightClassic: Bool {
        themeName == "Gratitude" && colorScheme == .light
    }
    
    private var gratitudeDarkClassic: Bool {
        themeName == "Gratitude" && colorScheme == .dark
    }
    
    private var stressAccentPink: Color {
        Color(red: 255 / 255, green: 45 / 255, blue: 85 / 255)
    }
    
    private var energyAccentOrange: Color {
        Color(red: 255 / 255, green: 141 / 255, blue: 40 / 255)
    }
    
    private var gratitudeGold: Color {
        Color(red: 255 / 255, green: 204 / 255, blue: 0)
    }
    
    /// ~#21436e unselected duration chip (Focus dark).
    private var focusMutedNavy: Color {
        Color(red: 33 / 255, green: 67 / 255, blue: 110 / 255)
    }
    
    private var focusAccentBlue: Color {
        Color(red: 0, green: 136 / 255, blue: 1)
    }
    
    private var themeColor: Color {
        switch themeName {
        case "Calm":
            return Color(red: 0.000, green: 0.784, blue: 0.702)
        case "Sleep":
            return Color(red: 0.380, green: 0.333, blue: 0.961)
        case "Focus":
            return Color(red: 0.000, green: 0.533, blue: 1.000)
        case "Stress Relief":
            return Color(red: 1.000, green: 0.176, blue: 0.333)
        case "Energy":
            return energyAccentOrange
        case "Gratitude":
            return gratitudeGold
        default:
            return .blue
        }
    }
    
    private var sleepSelectedBlue: Color {
        Color(red: 0.50, green: 0.68, blue: 0.98)
    }
    
    private var sleepLightPurple: Color {
        Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255)
    }
    
    private var selectedFill: Color {
        if calmLightClassic {
            return Color(red: 26 / 255, green: 188 / 255, blue: 156 / 255)
        }
        if sleepDarkClassic {
            return sleepSelectedBlue
        }
        if sleepLightClassic {
            return sleepLightPurple
        }
        if focusDarkClassic || focusLightClassic {
            return focusAccentBlue
        }
        if stressDarkClassic || stressLightClassic {
            return stressAccentPink
        }
        if energyDarkClassic || energyLightClassic {
            return energyAccentOrange
        }
        if gratitudeDarkClassic || gratitudeLightClassic {
            return gratitudeGold
        }
        return themeColor
    }
    
    private var unselectedFill: Color {
        if calmLightClassic {
            return Color(red: 0.94, green: 0.98, blue: 0.97)
        }
        if calmDarkClassic {
            return Color.white.opacity(0.14)
        }
        if sleepDarkClassic {
            return Color.white.opacity(0.12)
        }
        if sleepLightClassic {
            return Color.white.opacity(0.42)
        }
        if focusDarkClassic {
            return focusMutedNavy.opacity(0.88)
        }
        if focusLightClassic {
            return Color.white.opacity(0.45)
        }
        if stressDarkClassic {
            return Color.white.opacity(0.14)
        }
        if stressLightClassic {
            return Color.white.opacity(0.45)
        }
        if energyDarkClassic {
            return Color.white.opacity(0.14)
        }
        if energyLightClassic {
            return Color.white.opacity(0.45)
        }
        if gratitudeDarkClassic {
            return Color.white.opacity(0.14)
        }
        if gratitudeLightClassic {
            return Color.white.opacity(0.45)
        }
        return Color.clear
    }
    
    private var corner: CGFloat { usesReferenceCardStyle ? 18 : 16 }
    
    private var usesReferenceCardStyle: Bool {
        calmLightClassic || calmDarkClassic || sleepDarkClassic || sleepLightClassic || focusLightClassic || focusDarkClassic
            || stressLightClassic || stressDarkClassic || energyLightClassic || energyDarkClassic
            || gratitudeLightClassic || gratitudeDarkClassic
    }
    
    private var durationLabelForeground: Color {
        if isSelected { return .white }
        if calmLightClassic { return Color(red: 0.35, green: 0.38, blue: 0.40) }
        if calmDarkClassic { return .white }
        if sleepDarkClassic { return .white }
        if sleepLightClassic { return Color(red: 0.22, green: 0.18, blue: 0.45) }
        if focusDarkClassic { return .white }
        if focusLightClassic { return Color(red: 0.04, green: 0.20, blue: 0.44) }
        if stressDarkClassic { return .white }
        if stressLightClassic { return Color(red: 0.22, green: 0.06, blue: 0.14) }
        if energyDarkClassic { return .white }
        if energyLightClassic { return Color(red: 0.26, green: 0.11, blue: 0.03) }
        if gratitudeDarkClassic { return .white }
        if gratitudeLightClassic { return Color(red: 0.30, green: 0.20, blue: 0.02) }
        return Color.primary
    }
    
    private var durationCardShadowOpacity: Double {
        if isSelected && calmLightClassic { return 0.12 }
        if isSelected && calmDarkClassic { return 0.18 }
        if isSelected && sleepLightClassic { return 0.12 }
        if isSelected && sleepDarkClassic { return 0.18 }
        if isSelected && focusDarkClassic { return 0.18 }
        if isSelected && focusLightClassic { return 0.14 }
        if isSelected && stressDarkClassic { return 0.18 }
        if isSelected && stressLightClassic { return 0.14 }
        if isSelected && energyDarkClassic { return 0.18 }
        if isSelected && energyLightClassic { return 0.14 }
        if isSelected && gratitudeDarkClassic { return 0.18 }
        if isSelected && gratitudeLightClassic { return 0.14 }
        if isSelected { return 0.15 }
        return 0.06
    }
    
    private var durationCardBorderColor: Color {
        if isSelected { return .clear }
        if calmLightClassic { return Color.black.opacity(0.06) }
        if calmDarkClassic { return Color.white.opacity(0.12) }
        if sleepDarkClassic { return Color.white.opacity(0.1) }
        if sleepLightClassic { return Color.white.opacity(0.35) }
        if focusDarkClassic { return Color.white.opacity(0.12) }
        if focusLightClassic { return Color.white.opacity(0.4) }
        if stressDarkClassic { return Color.white.opacity(0.12) }
        if stressLightClassic { return Color.white.opacity(0.4) }
        if energyDarkClassic { return Color.white.opacity(0.12) }
        if energyLightClassic { return Color.white.opacity(0.4) }
        if gratitudeDarkClassic { return Color.white.opacity(0.12) }
        if gratitudeLightClassic { return Color.white.opacity(0.4) }
        return Color(.separator).opacity(0.5)
    }
    
    private var durationCardShadowY: CGFloat {
        calmLightClassic || sleepLightClassic || focusLightClassic || stressLightClassic || energyLightClassic || gratitudeLightClassic ? 3 : 4
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(duration)")
                    .font(usesReferenceCardStyle ? .brandDurationDigit : .brandNumber)
                Text("MIN")
                    .font(usesReferenceCardStyle ? .brandDurationMinLabel : .brandCaption)
                    .tracking(usesReferenceCardStyle ? 0.6 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, usesReferenceCardStyle ? 18 : 20)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(selectedFill)
                } else if usesReferenceCardStyle {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(unselectedFill)
                } else {
                    ZStack {
                        themeColor.opacity(colorScheme == .dark ? 0.15 : 0.08)
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .foregroundStyle(durationLabelForeground)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .shadow(
                color: .black.opacity(durationCardShadowOpacity),
                radius: usesReferenceCardStyle ? 8 : 10,
                x: 0,
                y: durationCardShadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(durationCardBorderColor, lineWidth: 1)
            )
            .scaleEffect(!usesReferenceCardStyle && isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(duration) minute meditation")
        .accessibilityHint("Double tap to select \(duration) minute duration")
    }
}

struct ExpectationRow: View {
    let icon: String
    let text: String
    var tint: Color = .secondary
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 26, alignment: .center)
            
            Text(text)
                .font(.brandSubheadline)
                .foregroundStyle(tint)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        MeditationDetailsView(theme: MeditationTheme.sampleThemes[0], sessionStore: SessionStore(), journalStore: JournalStore(), achievementsManager: AchievementsManager(), backgroundSoundManager: BackgroundSoundManager())
    }
}
