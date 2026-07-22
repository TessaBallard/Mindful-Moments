//
//  MeditationPlayerView.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import SwiftUI

/// S-003 — Meditation Player Screen
struct MeditationPlayerView: View {
    let theme: MeditationTheme
    let duration: Int
    let sessionStore: SessionStore
    let journalStore: JournalStore
    let moodBefore: Mood?
    let achievementsManager: AchievementsManager
    let backgroundSoundManager: BackgroundSoundManager
    var guidedVoiceEnabled: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var playerModel = MeditationPlayerModel()
    @State private var audioManager = MeditationAudioManager()
    @State private var showingEndAlert = false
    @State private var showingJournalPrompt = false
    @State private var showingMoodCheckOut = false
    @State private var showingCompletion = false
    @State private var showingAchievement: Achievement?
    @State private var isLoading = true
    @State private var loadingProgress: CGFloat = 0.0
    @State private var isPulsing = false
    @State private var pulseID = UUID()
    @State private var showSoundControls = false
    @AppStorage("backgroundVolume") private var savedBackgroundVolume: Double = 0.015
    
    private var isCalmLightPlayer: Bool {
        theme.name == "Calm" && colorScheme == .light
    }
    
    private var isCalmDarkPlayer: Bool {
        theme.name == "Calm" && colorScheme == .dark
    }
    
    private var isCalmPlayer: Bool {
        theme.name == "Calm"
    }
    
    private var isSleepPlayer: Bool {
        theme.name == "Sleep"
    }
    
    private var isSleepLightPlayer: Bool {
        theme.name == "Sleep" && colorScheme == .light
    }
    
    private var isSleepDarkPlayer: Bool {
        theme.name == "Sleep" && colorScheme == .dark
    }
    
    private var isFocusPlayer: Bool {
        theme.name == "Focus"
    }
    
    private var isFocusLightPlayer: Bool {
        theme.name == "Focus" && colorScheme == .light
    }
    
    private var isFocusDarkPlayer: Bool {
        theme.name == "Focus" && colorScheme == .dark
    }
    
    private var isStressReliefPlayer: Bool {
        theme.name == "Stress Relief"
    }
    
    private var isStressReliefLightPlayer: Bool {
        theme.name == "Stress Relief" && colorScheme == .light
    }
    
    private var isStressReliefDarkPlayer: Bool {
        theme.name == "Stress Relief" && colorScheme == .dark
    }
    
    private var isEnergyPlayer: Bool {
        theme.name == "Energy"
    }
    
    private var isEnergyLightPlayer: Bool {
        theme.name == "Energy" && colorScheme == .light
    }
    
    private var isEnergyDarkPlayer: Bool {
        theme.name == "Energy" && colorScheme == .dark
    }
    
    private var isGratitudePlayer: Bool {
        theme.name == "Gratitude"
    }
    
    private var isGratitudeLightPlayer: Bool {
        theme.name == "Gratitude" && colorScheme == .light
    }
    
    private var isGratitudeDarkPlayer: Bool {
        theme.name == "Gratitude" && colorScheme == .dark
    }
    
    private static let calmPlayerRingTrack = Color(red: 0.14, green: 0.52, blue: 0.47)
    private static let calmPlayerAccentButton = Color(red: 26 / 255, green: 188 / 255, blue: 156 / 255)
    private static let calmPlayerTitleText = Color(red: 0.05, green: 0.12, blue: 0.11)
    private static let calmPlayerSubtitleText = Color(red: 0.35, green: 0.42, blue: 0.41)
    
    /// Sleep player gradient (light + dark): #6155f5 → #a8a2f9
    private static let sleepPlayerPurpleTop = Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255)
    private static let sleepPlayerPurpleBottom = Color(red: 168 / 255, green: 162 / 255, blue: 249 / 255)
    private static let sleepPlayerAccent = Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255)
    
    /// Focus player: #0088ff → #99cfff (light); navy → #0088ff (dark).
    private static let focusPlayerBlue = Color(red: 0, green: 136 / 255, blue: 1)
    private static let focusPlayerBlueSoft = Color(red: 153 / 255, green: 207 / 255, blue: 1)
    private static let focusPlayerDarkNavyTop = Color(red: 0, green: 44 / 255, blue: 83 / 255) // #002c53
    
    /// Stress Relief: #ff2d55 → #ffb8c5 (light); deep maroon → #ff2d55 (dark).
    private static let stressPlayerAccent = Color(red: 255 / 255, green: 45 / 255, blue: 85 / 255)
    private static let stressPlayerPinkSoft = Color(red: 255 / 255, green: 184 / 255, blue: 197 / 255)
    private static let stressPlayerDarkMaroonTop = Color(red: 85 / 255, green: 0, blue: 18 / 255) // #550012
    
    /// Energy: #ff8d28 → #ffd4ab (light); deep brown → #ff8d28 (dark).
    private static let energyPlayerAccent = Color(red: 255 / 255, green: 141 / 255, blue: 40 / 255)
    private static let energyPlayerPeachSoft = Color(red: 255 / 255, green: 212 / 255, blue: 171 / 255)
    private static let energyPlayerDarkBrownTop = Color(red: 78 / 255, green: 34 / 255, blue: 0) // #4e2200
    
    /// Gratitude: #ffcc00 → #fff3c2 (light); dark top pairs with cream foot in `MeditationScreenGradients`.
    private static let gratitudePlayerGold = Color(red: 255 / 255, green: 204 / 255, blue: 0)
    private static let gratitudePlayerCream = Color(red: 255 / 255, green: 243 / 255, blue: 194 / 255)
    private static let gratitudePlayerDarkTop = Color(red: 77 / 255, green: 62 / 255, blue: 0)
    
    private var themeAccent: Color {
        if isCalmPlayer { return Self.calmPlayerAccentButton }
        if isSleepPlayer { return Self.sleepPlayerAccent }
        if isFocusPlayer { return Self.focusPlayerBlue }
        if isStressReliefPlayer { return Self.stressPlayerAccent }
        if isEnergyPlayer { return Self.energyPlayerAccent }
        if isGratitudePlayer { return Self.gratitudePlayerGold }
        return primaryColorForTheme(theme.name)
    }
    
    private var playerTitleForeground: Color {
        if isCalmLightPlayer { return Self.calmPlayerTitleText }
        if isCalmDarkPlayer { return .white }
        if isSleepLightPlayer { return Color.black }
        if isSleepDarkPlayer { return .white }
        if isFocusLightPlayer { return Color(red: 0.02, green: 0.12, blue: 0.28) }
        if isFocusDarkPlayer { return .white }
        if isStressReliefLightPlayer { return Color(red: 0.28, green: 0.04, blue: 0.12) }
        if isStressReliefDarkPlayer { return .white }
        if isEnergyLightPlayer { return Color(red: 0.32, green: 0.14, blue: 0.02) }
        if isEnergyDarkPlayer { return .white }
        if isGratitudeLightPlayer { return .white }
        if isGratitudeDarkPlayer { return .white }
        return Color.primary
    }
    
    private var playerSubtitleForeground: Color {
        if isCalmLightPlayer { return Self.calmPlayerSubtitleText }
        if isCalmDarkPlayer { return Color.white.opacity(0.86) }
        if isSleepLightPlayer { return Color(red: 0.38, green: 0.34, blue: 0.52) }
        if isSleepDarkPlayer { return Color.white.opacity(0.88) }
        if isFocusLightPlayer { return Color(red: 0.12, green: 0.30, blue: 0.48).opacity(0.92) }
        if isFocusDarkPlayer { return Color.white.opacity(0.82) }
        if isStressReliefLightPlayer { return Color(red: 0.48, green: 0.14, blue: 0.26).opacity(0.9) }
        if isStressReliefDarkPlayer { return Color.white.opacity(0.86) }
        if isEnergyLightPlayer { return Color(red: 0.50, green: 0.22, blue: 0.08).opacity(0.9) }
        if isEnergyDarkPlayer { return Color.white.opacity(0.82) }
        if isGratitudeLightPlayer { return Color.white.opacity(0.88) }
        if isGratitudeDarkPlayer { return Color.white.opacity(0.80) }
        return Color.secondary
    }
    
    private var playerRingTrackColor: Color {
        if isCalmPlayer { return Color.white.opacity(0.22) }
        if isSleepLightPlayer { return Self.sleepPlayerPurpleTop.opacity(0.38) }
        if isSleepDarkPlayer { return Self.sleepPlayerPurpleTop.opacity(0.38) }
        if isFocusLightPlayer { return Self.focusPlayerBlue.opacity(0.38) }
        if isFocusDarkPlayer { return Color.white.opacity(0.2) }
        if isStressReliefLightPlayer { return Self.stressPlayerAccent.opacity(0.38) }
        if isStressReliefDarkPlayer { return Color.white.opacity(0.22) }
        if isEnergyLightPlayer { return Self.energyPlayerAccent.opacity(0.38) }
        if isEnergyDarkPlayer { return Color.white.opacity(0.22) }
        if isGratitudeLightPlayer { return Self.gratitudePlayerGold.opacity(0.42) }
        if isGratitudeDarkPlayer { return Color.white.opacity(0.22) }
        return Color(.systemGray5).opacity(0.3)
    }
    
    private var playerRingProgressColor: Color {
        if isCalmPlayer { return Self.calmPlayerAccentButton }
        if isSleepLightPlayer { return Color(red: 0.40, green: 0.30, blue: 0.82) }
        if isSleepDarkPlayer { return Color(red: 0.40, green: 0.30, blue: 0.82) }
        if isFocusLightPlayer { return Color(red: 0, green: 0.42, blue: 0.95) }
        if isFocusDarkPlayer { return Self.focusPlayerBlue }
        if isStressReliefLightPlayer { return Self.stressPlayerAccent }
        if isStressReliefDarkPlayer { return Self.stressPlayerAccent }
        if isEnergyLightPlayer { return Self.energyPlayerAccent }
        if isEnergyDarkPlayer { return Self.energyPlayerAccent }
        if isGratitudeLightPlayer { return Self.gratitudePlayerGold }
        if isGratitudeDarkPlayer { return Self.gratitudePlayerGold }
        return primaryColorForTheme(theme.name)
    }
    
    private var playerSoundBarForeground: Color {
        if isCalmLightPlayer { return Self.calmPlayerSubtitleText }
        if isCalmDarkPlayer { return Color.white.opacity(0.88) }
        if isSleepLightPlayer { return Color(red: 0.42, green: 0.40, blue: 0.48) }
        if isSleepDarkPlayer { return Color.white.opacity(0.88) }
        if isFocusLightPlayer { return Color(red: 0.22, green: 0.36, blue: 0.52) }
        if isFocusDarkPlayer { return Color.white.opacity(0.9) }
        if isStressReliefLightPlayer { return Color(red: 0.38, green: 0.12, blue: 0.24) }
        if isStressReliefDarkPlayer { return Color.white.opacity(0.9) }
        if isEnergyLightPlayer { return Color(red: 0.42, green: 0.20, blue: 0.08) }
        if isEnergyDarkPlayer { return Color.white.opacity(0.88) }
        if isGratitudeLightPlayer { return Color.white }
        if isGratitudeDarkPlayer { return Color.white.opacity(0.9) }
        return Color.secondary
    }
    
    /// Same SF Rounded digit style in light and dark (52pt medium + `.monospacedDigit()` on the `Text`).
    private var playerTimerDisplayFont: Font {
        switch theme.name {
        case "Calm", "Sleep", "Focus", "Stress Relief", "Energy", "Gratitude":
            return Font.appScaledSystem(size: 52, weight: .medium, design: .rounded)
        default:
            return .brandTimer
        }
    }
    
    private var referencePlayerVerticalLayout: Bool {
        isCalmPlayer || isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer
    }
    
    private var playerThemeTitleFont: Font {
        if isCalmLightPlayer { return Font.appScaledSystem(size: 22, weight: .semibold, design: .rounded) }
        if isCalmDarkPlayer { return Font.appScaledSystem(size: 22, weight: .semibold, design: .rounded) }
        if isSleepLightPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isSleepDarkPlayer { return Font.appScaledSystem(size: 22, weight: .semibold, design: .rounded) }
        if isFocusLightPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isFocusDarkPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isStressReliefLightPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isStressReliefDarkPlayer { return Font.appScaledSystem(size: 22, weight: .semibold, design: .rounded) }
        if isEnergyLightPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isEnergyDarkPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isGratitudeLightPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        if isGratitudeDarkPlayer { return Font.appScaledSystem(size: 22, weight: .bold, design: .rounded) }
        return .brandTitle3
    }
    
    /// Reference themes share the same ring chrome logic (Calm, Sleep, Focus, Stress Relief, Energy, Gratitude).
    private var referenceRingChrome: Bool {
        isCalmPlayer || isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer
    }
    
    /// Matches `MeditationDetailsView` start-button shadow (player flags).
    private var endSessionButtonShadowColor: Color {
        if isSleepDarkPlayer { return Color(red: 0.52, green: 0.66, blue: 1.0).opacity(0.45) }
        if isSleepLightPlayer { return Color(red: 97 / 255, green: 85 / 255, blue: 245 / 255).opacity(0.42) }
        if isCalmLightPlayer { return Self.calmPlayerAccentButton.opacity(0.35) }
        if isCalmDarkPlayer { return Self.calmPlayerAccentButton.opacity(0.42) }
        if isFocusDarkPlayer || isFocusLightPlayer { return Self.focusPlayerBlue.opacity(0.42) }
        if isStressReliefDarkPlayer || isStressReliefLightPlayer { return Self.stressPlayerAccent.opacity(0.42) }
        if isEnergyDarkPlayer || isEnergyLightPlayer { return Self.energyPlayerAccent.opacity(0.42) }
        if isGratitudeDarkPlayer || isGratitudeLightPlayer { return Self.gratitudePlayerGold.opacity(0.42) }
        return primaryColorForTheme(theme.name).opacity(0.35)
    }
    
    /// Same fills as detail screen “Start Session” (`cornerRadius` 26).
    @ViewBuilder
    private var endSessionButtonBackground: some View {
        if isSleepDarkPlayer {
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
        } else if isSleepLightPlayer {
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
        } else if isCalmLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.calmPlayerAccentButton)
        } else if isFocusDarkPlayer || isFocusLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.focusPlayerBlue)
        } else if isStressReliefDarkPlayer || isStressReliefLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.stressPlayerAccent)
        } else if isEnergyDarkPlayer || isEnergyLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.energyPlayerAccent)
        } else if isGratitudeDarkPlayer || isGratitudeLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.gratitudePlayerGold)
        } else {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(primaryColorForTheme(theme.name))
        }
    }
    
    private var playButtonGlowOpacity: Double {
        isCalmPlayer ? 0.45 : (referenceRingChrome ? 0.42 : 0.4)
    }
    
    private var playButtonGlowRadius: CGFloat {
        isCalmPlayer ? 10 : (referenceRingChrome ? 11 : 12)
    }
    
    private var playButtonGlowY: CGFloat {
        isCalmPlayer ? 4 : (referenceRingChrome ? 5 : 6)
    }
    
    private var playerRingLineWidth: CGFloat { isCalmPlayer ? 10 : 12 }
    private var playerRingDiameter: CGFloat { 280 }
    
    @ViewBuilder
    private var mainPlayerRingAndPlayTransport: some View {
        let ringLine = playerRingLineWidth
        let ringSize = playerRingDiameter
        let refLayout = referencePlayerVerticalLayout
        
        ZStack {
            Circle()
                .stroke(
                    referenceRingChrome
                        ? playerRingTrackColor
                        : Color(.systemGray5).opacity(0.3),
                    lineWidth: ringLine
                )
                .frame(width: ringSize, height: ringSize)
            
            Circle()
                .trim(from: 0, to: playerModel.progress)
                .stroke(
                    referenceRingChrome
                        ? playerRingProgressColor
                        : primaryColorForTheme(theme.name),
                    style: StrokeStyle(lineWidth: ringLine, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: playerModel.progress)
            
            VStack(spacing: 8) {
                Text(playerModel.timeString)
                    .font(playerTimerDisplayFont)
                    .monospacedDigit()
                    .foregroundStyle(refLayout ? playerTitleForeground : Color.primary)
                
                if !playerModel.isPlaying && playerModel.timeRemaining > 0 {
                    if isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudeDarkPlayer {
                        Text("Paused")
                            .font(.appScaledSystem(size: 11, weight: .semibold, design: .rounded))
                            .textCase(.uppercase)
                            .foregroundStyle(playerSubtitleForeground)
                    } else if isGratitudeLightPlayer {
                        Text("Paused")
                            .font(.brandCaption)
                            .foregroundStyle(Color(red: 1, green: 0.94, blue: 0.62).opacity(0.92))
                    } else {
                        Text("Paused")
                            .font(.brandCaption)
                            .foregroundStyle(refLayout ? playerSubtitleForeground : Color.secondary)
                    }
                }
            }
        }
        
        Button(action: {
            HapticManager.light()
            if playerModel.isPlaying {
                playerModel.pause()
                audioManager.pause()
                isPulsing = false
            } else {
                playerModel.play()
                audioManager.resume()
                pulseID = UUID()
                if isSleepPlayer {
                    isPulsing = true
                }
            }
        }) {
            ZStack {
                if playerModel.isPlaying && !isCalmPlayer && !isSleepPlayer && !isFocusPlayer && !isStressReliefPlayer && !isEnergyPlayer && !isGratitudePlayer {
                    Circle()
                        .fill(primaryColorForTheme(theme.name).opacity(0.3))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0.3 : 0.7)
                        .animation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .onAppear {
                            isPulsing = true
                        }
                        .id(pulseID)
                }
                
                if isSleepPlayer {
                    Circle()
                        .stroke(Self.sleepPlayerAccent.opacity(0.34), lineWidth: 2)
                        .frame(width: 92, height: 92)
                        .scaleEffect(playerModel.isPlaying && isPulsing ? 1.06 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.4)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                    Circle()
                        .stroke(Self.sleepPlayerAccent.opacity(0.20), lineWidth: 2)
                        .frame(width: 104, height: 104)
                        .scaleEffect(playerModel.isPlaying && isPulsing ? 1.04 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.4)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }
                
                if isCalmLightPlayer {
                    Circle()
                        .stroke(Self.calmPlayerRingTrack.opacity(0.85), lineWidth: 3)
                        .frame(width: 86, height: 86)
                }
                
                Circle()
                    .fill(themeAccent)
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: themeAccent.opacity(playButtonGlowOpacity),
                        radius: playButtonGlowRadius,
                        x: 0,
                        y: playButtonGlowY
                    )
                
                Image(systemName: playerModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.appScaledSystem(size: 32, design: .rounded))
                    .foregroundStyle(.white)
                    .offset(x: playerModel.isPlaying ? 0 : 2)
            }
        }
        .disabled(playerModel.timeRemaining == 0)
        .scaleEffect(referenceRingChrome ? 1.0 : (playerModel.isPlaying ? 1.0 : 0.95))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: playerModel.isPlaying)
        .accessibilityLabel(playerModel.isPlaying ? "Pause meditation" : "Resume meditation")
        .accessibilityHint("Double tap to \(playerModel.isPlaying ? "pause" : "resume") the guided meditation")
    }
    
    @ViewBuilder
    private var expandedSoundPanelRectangleBackground: some View {
        if isCalmLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.38))
        } else if isCalmDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.24))
        } else if isSleepLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.55))
        } else if isSleepDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.32))
        } else if isFocusLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.55))
        } else if isFocusDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0, green: 0.12, blue: 0.28).opacity(0.45))
        } else if isStressReliefLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.55))
        } else if isStressReliefDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.22, green: 0.04, blue: 0.10).opacity(0.52))
        } else if isEnergyLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.55))
        } else if isEnergyDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.12, green: 0.05, blue: 0.02).opacity(0.55))
        } else if isGratitudeLightPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.43, green: 0.36, blue: 0.28).opacity(0.62))
        } else if isGratitudeDarkPlayer {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Self.gratitudePlayerDarkTop.opacity(0.72))
        } else {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
    
    private var soundMuteButtonMutedFill: Color {
        if isCalmLightPlayer { return Color.white.opacity(0.25) }
        if isCalmDarkPlayer { return Color.white.opacity(0.18) }
        if isSleepLightPlayer { return Color.white.opacity(0.4) }
        if isSleepDarkPlayer { return Color.white.opacity(0.22) }
        if isFocusLightPlayer { return Color.white.opacity(0.42) }
        if isFocusDarkPlayer { return Color.white.opacity(0.18) }
        if isStressReliefLightPlayer { return Color.white.opacity(0.42) }
        if isStressReliefDarkPlayer { return Color.white.opacity(0.18) }
        if isEnergyLightPlayer { return Color.white.opacity(0.42) }
        if isEnergyDarkPlayer { return Color.white.opacity(0.18) }
        if isGratitudeLightPlayer { return Color.white.opacity(0.28) }
        if isGratitudeDarkPlayer { return Color.white.opacity(0.18) }
        return Color(.systemGray6)
    }
    
    private var soundMuteButtonUnmutedAccentOpacity: Double {
        isCalmPlayer ? 0.22 : ((isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer) ? 0.24 : 0.15)
    }
    
    @ViewBuilder
    private var playerSoundVolumeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Volume")
                    .font(.brandCaption)
                    .foregroundStyle(referenceRingChrome ? playerSoundBarForeground : Color.secondary)
                
                Spacer()
                
                Text(audioManager.isBackgroundMuted ? "Muted" : "\(Int(audioManager.backgroundVolume * 100))%")
                    .font(.brandCaption)
                    .foregroundStyle(referenceRingChrome ? playerSoundBarForeground : Color.secondary)
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.appScaledSystem(size: 12, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .frame(width: 20)
                
                Slider(
                    value: Binding(
                        get: { Double(audioManager.backgroundVolume) },
                        set: { newValue in
                            audioManager.setBackgroundVolume(Float(newValue))
                            savedBackgroundVolume = newValue
                        }
                    ),
                    in: 0...0.1,
                    step: 0.005
                )
                .tint(themeAccent)
                .accessibilityLabel("Background sound volume")
                .accessibilityValue("\(Int(audioManager.backgroundVolume * 1000)) percent")
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.appScaledSystem(size: 12, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .frame(width: 20)
            }
        }
    }
    
    @ViewBuilder
    private var playerSoundMuteButton: some View {
        Button(action: {
            HapticManager.selection()
            audioManager.toggleBackgroundMute()
            if !audioManager.isBackgroundMuted {
                savedBackgroundVolume = Double(audioManager.backgroundVolume)
            }
        }) {
            HStack {
                Image(systemName: audioManager.isBackgroundMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.appScaledSystem(size: 14, design: .rounded))
                
                Text(audioManager.isBackgroundMuted ? "Unmute" : "Mute")
                    .font(.brandSubheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(
                audioManager.isBackgroundMuted
                    ? (referenceRingChrome ? playerSoundBarForeground : Color.secondary)
                    : themeAccent
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                audioManager.isBackgroundMuted
                    ? soundMuteButtonMutedFill
                    : themeAccent.opacity(soundMuteButtonUnmutedAccentOpacity)
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(audioManager.isBackgroundMuted ? "Unmute background sounds" : "Mute background sounds")
        .accessibilityHint("Double tap to \(audioManager.isBackgroundMuted ? "unmute" : "mute") the ambient background audio")
    }
    
    @ViewBuilder
    private var playerSoundExpandedPanel: some View {
        VStack(spacing: 16) {
            playerSoundVolumeSection
            playerSoundMuteButton
        }
        .padding(16)
        .background { expandedSoundPanelRectangleBackground }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }
    
    @ViewBuilder
    private var mainPlayerSoundAndEndArea: some View {
        VStack(spacing: 12) {
            Button(action: {
                HapticManager.selection()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSoundControls.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: audioManager.isBackgroundMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.appScaledSystem(size: 14, design: .rounded))
                    
                    Text("Background Sounds")
                        .font(.brandSubheadline)
                    
                    Spacer()
                    
                    Image(systemName: showSoundControls ? "chevron.up" : "chevron.down")
                        .font(.appScaledSystem(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(referenceRingChrome ? playerSoundBarForeground : Color.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    if isCalmLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.38))
                    } else if isCalmDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.22))
                    } else if isSleepLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.55))
                    } else if isSleepDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.32))
                    } else if isFocusLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.55))
                    } else if isFocusDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(red: 0, green: 0.12, blue: 0.28).opacity(0.45))
                    } else if isStressReliefLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.55))
                    } else if isStressReliefDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(red: 0.22, green: 0.04, blue: 0.10).opacity(0.52))
                    } else if isEnergyLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.55))
                    } else if isEnergyDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(red: 0.12, green: 0.05, blue: 0.02).opacity(0.55))
                    } else if isGratitudeLightPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(red: 0.43, green: 0.36, blue: 0.28).opacity(0.62))
                    } else if isGratitudeDarkPlayer {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Self.gratitudePlayerDarkTop.opacity(0.72))
                    } else {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .buttonStyle(.plain)
            
            if showSoundControls {
                playerSoundExpandedPanel
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
        
        Button(action: {
            HapticManager.light()
            showingEndAlert = true
        }) {
            Text("End Session")
                .font(.brandHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background { endSessionButtonBackground }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: endSessionButtonShadowColor, radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, referenceRingChrome ? 24 : 32)
        .padding(.bottom, 40)
    }
    
    private var playerBackground: some View {
        LinearGradient(
            colors: MeditationScreenGradients.themeColors(themeName: theme.name, isDark: colorScheme == .dark),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        ZStack {
            playerBackground
                .ignoresSafeArea()
            
            mainPlayerContent
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground((isCalmPlayer || isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer) ? .hidden : .automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingEndAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.appScaledSystem(size: 15, weight: .semibold, design: .rounded))
                        Text("Back")
                            .font(.appScaledSystem(size: 16, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(
                        isCalmLightPlayer
                            ? Self.calmPlayerTitleText
                            : isCalmDarkPlayer
                                ? Color.white
                            : isSleepLightPlayer
                                ? Color.primary
                                : isSleepDarkPlayer
                                    ? Color.white
                                    : isFocusLightPlayer
                                        ? Color.primary
                                        : isFocusDarkPlayer
                                            ? Color.white
                                            : isStressReliefLightPlayer
                                                ? Color.primary
                                                : isStressReliefDarkPlayer
                                                    ? Color.white
                                                    : isEnergyLightPlayer
                                                        ? Color.primary
                                                        : isEnergyDarkPlayer
                                                            ? Color.white
                                                            : isGratitudeLightPlayer
                                                                ? Color.white
                                                                : isGratitudeDarkPlayer
                                                                    ? Color.white
                                                                    : Color.primary
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if isCalmLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.38))
                        } else if isCalmDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.35))
                        } else if isSleepLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.52))
                        } else if isSleepDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.22))
                        } else if isFocusLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.52))
                        } else if isFocusDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.35))
                        } else if isStressReliefLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.52))
                        } else if isStressReliefDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.35))
                        } else if isEnergyLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.52))
                        } else if isEnergyDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.35))
                        } else if isGratitudeLightPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.45))
                        } else if isGratitudeDarkPlayer {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.35))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .alert("End Session?", isPresented: $showingEndAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                playerModel.stop()
                audioManager.stopMeditation()
                saveSession(moodAfter: nil)  // No mood check-out when ending early
                dismiss()
                ReviewPromptManager.requestReviewIfEligible(afterDelay: 1.0)
            }
        } message: {
            Text("Your progress will be saved.")
        }
        .onAppear(perform: handleOnAppear)
        .onDisappear {
            playerModel.stop()
            audioManager.stopMeditation()
        }
        .onChange(of: playerModel.isCompleted) { _, isCompleted in
            if isCompleted {
                // Session completed naturally
                HapticManager.success()
                audioManager.stopMeditation()
                // Show completion celebration
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingCompletion = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingMoodCheckOut) {
            moodCheckOutCover
        }
        .alert("Great Session!", isPresented: $showingJournalPrompt) {
            Button("Write Journal Entry") {
                dismiss()
                ReviewPromptManager.requestReviewIfEligible(afterDelay: 1.0)
                // Note: Parent view will handle navigation to journal
            }
            Button("Done", role: .cancel) {
                dismiss()
                ReviewPromptManager.requestReviewIfEligible(afterDelay: 1.0)
            }
        } message: {
            Text("Would you like to reflect on your meditation in your journal?")
        }
        .alert("Audio Error", isPresented: Binding(
            get: { audioManager.audioError != nil },
            set: { if !$0 { audioManager.audioError = nil } }
        )) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(audioManager.audioError ?? "")
        }
        .overlay {
            playerOverlays
        }
    }
    
    private func handleOnAppear() {
        HapticManager.medium()
        // Restore saved background volume
        audioManager.setBackgroundVolume(Float(savedBackgroundVolume))
        
        // Animate loading progress from 0 to 100%
        withAnimation(.easeInOut(duration: 0.8)) {
            loadingProgress = 1.0
        }
        
        // Simulate loading audio (in real app, this would wait for audio to load)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.4)) {
                isLoading = false
            }
            
            // Start after loading animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playerModel.setup(duration: duration)
                playerModel.play()
                if theme.name == "Sleep" {
                    isPulsing = true
                }
                
                // Start audio guidance with theme-specific file and duration
                audioManager.startMeditation(themeName: theme.name, duration: duration, backgroundSound: backgroundSoundManager.selectedSound, guidedVoice: guidedVoiceEnabled)
            }
        }
    }
    
    @ViewBuilder
    private var moodCheckOutCover: some View {
        NavigationStack {
            MoodCheckInView(
                timing: .after,
                onMoodSelected: { moodAfter in
                    saveSession(moodAfter: moodAfter)
                    showingMoodCheckOut = false
                    // Check for achievements first, if none, show journal prompt
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Only show journal prompt if no achievements
                        if achievementsManager.newlyUnlockedAchievements.isEmpty {
                            showingJournalPrompt = true
                        }
                        // Otherwise, achievement will show and handle journal in its onDismiss
                    }
                },
                onSkip: {
                    saveSession(moodAfter: nil)
                    showingMoodCheckOut = false
                    // Check for achievements first, if none, show journal prompt
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Only show journal prompt if no achievements
                        if achievementsManager.newlyUnlockedAchievements.isEmpty {
                            showingJournalPrompt = true
                        }
                        // Otherwise, achievement will show and handle journal in its onDismiss
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var playerOverlays: some View {
        // Loading state overlay
        if isLoading {
            loadingOverlay
        }
        
        // Completion celebration overlay
        if showingCompletion {
            CompletionCelebrationView(
                theme: theme,
                duration: duration,
                streakCount: sessionStore.projectedStreakAfterSessionToday,
                onDismiss: {
                    showingCompletion = false
                    showingMoodCheckOut = true
                }
            )
            .transition(.opacity)
        }
        
        // Achievement celebration overlay
        if let achievement = showingAchievement {
            AchievementCelebrationView(
                achievement: achievement,
                onDismiss: {
                    showingAchievement = nil
                    achievementsManager.clearNewlyUnlocked()
                    // Show journal prompt after achievement
                    showingJournalPrompt = true
                }
            )
            .transition(.opacity)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            LinearGradient(
                colors: MeditationScreenGradients.themeColors(themeName: theme.name, isDark: colorScheme == .dark),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isCalmPlayer ? Self.calmPlayerAccentButton : (isSleepPlayer ? Self.sleepPlayerAccent : (isFocusPlayer ? Self.focusPlayerBlue : (isStressReliefPlayer ? Self.stressPlayerAccent : (isEnergyPlayer ? Self.energyPlayerAccent : (isGratitudePlayer ? Self.gratitudePlayerGold : primaryColorForTheme(theme.name))))))).opacity(0.35),
                                    (isCalmPlayer ? Self.calmPlayerAccentButton : (isSleepPlayer ? Self.sleepPlayerAccent : (isFocusPlayer ? Self.focusPlayerBlue : (isStressReliefPlayer ? Self.stressPlayerAccent : (isEnergyPlayer ? Self.energyPlayerAccent : (isGratitudePlayer ? Self.gratitudePlayerGold : primaryColorForTheme(theme.name))))))).opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(
                            (isCalmPlayer ? Color.white.opacity(0.22) : ((isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer) ? playerRingTrackColor : primaryColorForTheme(theme.name).opacity(0.2))),
                            style: StrokeStyle(lineWidth: 4)
                        )
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: loadingProgress)
                        .stroke(
                            isCalmPlayer ? Self.calmPlayerAccentButton : ((isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer) ? playerRingProgressColor : primaryColorForTheme(theme.name)),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: loadingProgress)
                }
                
                VStack(spacing: 8) {
                    Text("Preparing Your Session")
                        .font(.brandHeadline)
                        .foregroundStyle(isCalmPlayer || isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer ? playerTitleForeground : Color.primary)
                    
                    Text("Get comfortable and ready to relax")
                        .font(.brandSubheadline)
                        .foregroundStyle(isCalmPlayer || isSleepPlayer || isFocusPlayer || isStressReliefPlayer || isEnergyPlayer || isGratitudePlayer ? playerSubtitleForeground : Color.secondary)
                }
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private var mainPlayerContent: some View {
        let refLayout = referencePlayerVerticalLayout
        
        VStack(spacing: refLayout ? 24 : 40) {
                if refLayout {
                    Spacer(minLength: 0)
                } else {
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    Text(theme.name)
                        .font(playerThemeTitleFont)
                        .foregroundStyle(refLayout ? playerTitleForeground : Color.primary)
                    
                    Text(theme.description)
                        .font(.brandSubheadline)
                        .foregroundStyle(refLayout ? playerSubtitleForeground : Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
                .animation(.easeIn(duration: 0.6), value: true)
                
                Spacer(minLength: refLayout ? 12 : 0)
                
                mainPlayerRingAndPlayTransport
                
                Spacer()
                
                mainPlayerSoundAndEndArea
            }
    }
    
    /// F-004 — Save completed session
    private func saveSession(moodAfter: Mood?) {
        let actualDuration = duration - (playerModel.timeRemaining / 60)
        
        // Only save if at least 1 minute was completed
        guard actualDuration > 0 else { return }
        
        let session = MeditationSession(
            duration: actualDuration,
            themeName: theme.name,
            themeColor: theme.color,
            themeIcon: theme.iconName,
            moodBefore: moodBefore,
            moodAfter: moodAfter
        )
        
        sessionStore.addSession(session)
        ReviewPromptManager.recordCompletedActivity()
        
        // Check for newly unlocked achievements
        let newAchievements = achievementsManager.checkForNewAchievements(sessionStore: sessionStore)
        
        // Show celebration for first new achievement
        if let firstAchievement = newAchievements.first {
            // Delay slightly to let mood check-out dismiss first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showingAchievement = firstAchievement
            }
        }
    }
    
    private func colorForTheme(_ colorName: String) -> Color {
        switch colorName {
        case "mint": return .mint
        case "indigo": return .indigo
        case "blue": return .blue
        case "pink": return .pink
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    private func primaryColorForTheme(_ themeName: String) -> Color {
        // Return the brighter color from the gradient for UI elements
        switch themeName {
        case "Calm":
            return Color(red: 0.000, green: 0.784, blue: 0.702)  // #00c8b3
        case "Sleep":
            return Color(red: 0.380, green: 0.333, blue: 0.961)  // #6155f5
        case "Focus":
            return Color(red: 0.000, green: 0.533, blue: 1.000)  // #0088ff
        case "Stress Relief":
            return Color(red: 1.000, green: 0.176, blue: 0.333)  // #ff2d55
        case "Energy":
            return Color(red: 255 / 255, green: 141 / 255, blue: 40 / 255)  // #ff8d28
        case "Gratitude":
            return Color(red: 255 / 255, green: 204 / 255, blue: 0)  // #ffcc00
        default:
            return .blue
        }
    }
}

#Preview {
    NavigationStack {
        MeditationPlayerView(
            theme: MeditationTheme.sampleThemes[0],
            duration: 5,
            sessionStore: SessionStore(),
            journalStore: JournalStore(),
            moodBefore: .stressed,
            achievementsManager: AchievementsManager(),
            backgroundSoundManager: BackgroundSoundManager()
        )
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        MeditationPlayerView(
            theme: MeditationTheme.sampleThemes[1],
            duration: 10,
            sessionStore: SessionStore(),
            journalStore: JournalStore(),
            moodBefore: .anxious,
            achievementsManager: AchievementsManager(),
            backgroundSoundManager: BackgroundSoundManager()
        )
    }
    .preferredColorScheme(.dark)
}

