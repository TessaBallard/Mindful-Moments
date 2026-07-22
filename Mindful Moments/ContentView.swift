//
//  ContentView.swift
//  Mindful Moments
//
//  Main home screen with meditation selection
//

import SwiftUI

// MARK: - Home liquid glass (background gradient unchanged in `ContentView` body)

private enum HomeGlass {
    static let cardRadius: CGFloat = 26
    static let pillRadius: CGFloat = 22
    
    static func primaryText(isDark: Bool) -> Color {
        isDark ? .white : Color(red: 0.08, green: 0.1, blue: 0.12)
    }
    
    static func secondaryText(isDark: Bool) -> Color {
        isDark ? Color.white.opacity(0.72) : Color(red: 0.38, green: 0.42, blue: 0.46)
    }
}

private struct LiquidGlassCardBackground: View {
    let isDark: Bool
    var cornerRadius: CGFloat = HomeGlass.cardRadius
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    isDark
                        ? Color(red: 0.10, green: 0.14, blue: 0.24).opacity(0.52)
                        : Color(red: 0.92, green: 0.97, blue: 1.0).opacity(0.42)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDark ? 0.24 : 0.65),
                            Color.white.opacity(isDark ? 0.05 : 0.12),
                            Color.black.opacity(isDark ? 0.25 : 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(isDark ? 0.38 : 0.14), radius: 16, x: 0, y: 10)
        .shadow(color: Color.black.opacity(isDark ? 0.2 : 0.05), radius: 2, x: 0, y: 1)
    }
}

private struct ThemeIconBloom: View {
    let color: Color
    let systemName: String
    var iconFontSize: CGFloat = 26
    var circleDiameter: CGFloat = 56
    var isDark: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(isDark ? 0.55 : 0.42))
                .frame(width: circleDiameter + 22, height: circleDiameter + 22)
                .blur(radius: 12)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(isDark ? 0.32 : 0.22),
                            color.opacity(isDark ? 0.14 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: circleDiameter, height: circleDiameter)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(isDark ? 0.12 : 0.35), lineWidth: 1)
                }
            Image(systemName: systemName)
                .font(.appScaledSystem(size: iconFontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

private func homeIconColor(for colorName: String, isDark: Bool) -> Color {
    if isDark {
        switch colorName {
        case "mint": return Color(red: 0.40, green: 0.90, blue: 0.85)
        case "indigo": return Color(red: 0.62, green: 0.55, blue: 1.0)
        case "blue": return Color(red: 0.42, green: 0.76, blue: 1.0)
        case "pink": return Color(red: 1.0, green: 0.45, blue: 0.55)
        case "orange": return Color(red: 1.0, green: 0.62, blue: 0.28)
        case "yellow": return Color(red: 1.0, green: 0.88, blue: 0.35)
        case "cyan": return Color(red: 0.45, green: 0.92, blue: 0.95)
        default: return .white
        }
    } else {
        switch colorName {
        case "mint": return Color(red: 0.0, green: 0.52, blue: 0.48)
        case "indigo": return Color(red: 0.35, green: 0.25, blue: 0.72)
        case "blue": return Color(red: 0.0, green: 0.42, blue: 0.82)
        case "pink": return Color(red: 0.92, green: 0.25, blue: 0.42)
        case "orange": return Color(red: 0.95, green: 0.48, blue: 0.12)
        case "yellow": return Color(red: 0.85, green: 0.68, blue: 0.0)
        case "cyan": return Color(red: 0.0, green: 0.52, blue: 0.62)
        default: return Color(red: 0.1, green: 0.12, blue: 0.16)
        }
    }
}

struct ContentView: View {
    @State private var sessionStore = SessionStore()
    @State private var journalStore = JournalStore()
    @State private var notificationManager = NotificationManager()
    @State private var favoritesManager = FavoritesManager()
    @State private var achievementsManager = AchievementsManager()
    @State private var backgroundSoundManager = BackgroundSoundManager()
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("hasSeenBackgroundSoundTip") private var hasSeenBackgroundSoundTip = false
    @AppStorage("hasSeenReminderTip") private var hasSeenReminderTip = false
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeData = Date().timeIntervalSince1970
    
    private var shouldShowBackgroundSoundTip: Bool {
        !hasSeenBackgroundSoundTip && sessionStore.totalSessions >= 2
    }

    private var shouldShowReminderTip: Bool {
        !hasSeenReminderTip && !dailyReminderEnabled && sessionStore.totalSessions >= 1
    }

    private var reminderTime: Date {
        Date(timeIntervalSince1970: reminderTimeData)
    }
    
    private var favoriteThemes: [MeditationTheme] {
        MeditationTheme.sampleThemes.filter { favoritesManager.isFavorite($0.name) }
    }
    
    private var isHomeDark: Bool { colorScheme == .dark }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    // Header (title centered; settings top-trailing)
                    ZStack(alignment: .top) {
                        VStack(spacing: 6) {
                            Text("Mindful Moments")
                                .font(.appScaledSystem(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                            
                            Text("Pause. Breathe. Be.")
                                .font(.appScaledSystem(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(HomeGlass.secondaryText(isDark: isHomeDark))
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        
                        HStack {
                            Spacer()
                            NavigationLink(destination: SettingsView(notificationManager: notificationManager, backgroundSoundManager: backgroundSoundManager)) {
                                Image(systemName: "gearshape.fill")
                                    .font(.appScaledSystem(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(isHomeDark ? Color.white : Color(red: 0.05, green: 0.35, blue: 0.72))
                                    .frame(width: 46, height: 46)
                                    .background {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay {
                                                Circle()
                                                    .fill(isHomeDark ? Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.55) : Color.white.opacity(0.45))
                                            }
                                            .overlay {
                                                Circle()
                                                    .stroke(Color.white.opacity(isHomeDark ? 0.15 : 0.5), lineWidth: 1)
                                            }
                                    }
                                    .shadow(color: .black.opacity(isHomeDark ? 0.35 : 0.12), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityHint("Open app settings to customize background sounds and notifications")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Background Sound Tip (after 2 sessions)
                    if shouldShowBackgroundSoundTip {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: "lightbulb.fill")
                                .font(.appScaledSystem(size: 22, design: .rounded))
                                .foregroundStyle(Color(red: 1.0, green: 0.88, blue: 0.2))
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Did you know?")
                                    .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                                Text("Choose from 8 background sounds in Settings — tap the gear icon above.")
                                    .font(.appScaledSystem(size: 14, weight: .regular, design: .rounded))
                                    .foregroundStyle(HomeGlass.secondaryText(isDark: isHomeDark))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer(minLength: 8)
                            
                            Button(action: {
                                withAnimation {
                                    hasSeenBackgroundSoundTip = true
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.appScaledSystem(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(HomeGlass.secondaryText(isDark: isHomeDark))
                                    .frame(width: 30, height: 30)
                                    .background {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay { Circle().fill(Color.black.opacity(isHomeDark ? 0.25 : 0.06)) }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background {
                            LiquidGlassCardBackground(isDark: isHomeDark, cornerRadius: HomeGlass.cardRadius)
                        }
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    // Daily reminder tip (after 1 session, if reminders off)
                    if shouldShowReminderTip {
                        HomeReminderTipCard(
                            isDark: isHomeDark,
                            onEnable: {
                                HapticManager.selection()
                                withAnimation {
                                    hasSeenReminderTip = true
                                    dailyReminderEnabled = true
                                }
                                Task {
                                    await notificationManager.scheduleDailyReminder(at: reminderTime)
                                }
                            },
                            onDismiss: {
                                withAnimation {
                                    hasSeenReminderTip = true
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    // Streak — tap through to Progress
                    NavigationLink(destination: ProgressView(sessionStore: sessionStore)) {
                        HomeStreakCard(currentStreak: sessionStore.currentStreak, isDark: isHomeDark)
                    }
                    .buttonStyle(SpringScaleButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Quick Breathing Exercise Card
                    NavigationLink(destination: BreathingExerciseView(
                        sessionStore: sessionStore,
                        achievementsManager: achievementsManager
                    )) {
                        QuickBreathingCard()
                    }
                    .buttonStyle(SpringScaleButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Recently Played
                    if let recentSession = sessionStore.mostRecentSession {
                        let isQuickBreathing = recentSession.themeName == "Quick Breathing"
                        let recentTheme = MeditationTheme.sampleThemes.first(where: { $0.name == recentSession.themeName })

                        if isQuickBreathing || recentTheme != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                        .font(.appScaledSystem(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(isHomeDark ? Color(red: 0.62, green: 0.55, blue: 1.0) : Color(red: 0.42, green: 0.28, blue: 0.78))
                                    
                                    Text("Recently Played")
                                        .font(.appScaledSystem(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                                }
                                .padding(.horizontal, 20)
                                
                                if isQuickBreathing {
                                    RecentlyPlayedBreathingCard(
                                        session: recentSession,
                                        sessionStore: sessionStore,
                                        achievementsManager: achievementsManager
                                    )
                                    .padding(.horizontal, 20)
                                } else if let recentTheme {
                                    RecentlyPlayedCard(
                                        session: recentSession,
                                        theme: recentTheme,
                                        sessionStore: sessionStore,
                                        journalStore: journalStore,
                                        favoritesManager: favoritesManager,
                                        achievementsManager: achievementsManager,
                                        backgroundSoundManager: backgroundSoundManager
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    
                    // Favorites Section
                    if !favoriteThemes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.appScaledSystem(size: 16, design: .rounded))
                                    .foregroundStyle(.yellow)
                                
                                Text("Your Favorites")
                                    .font(.appScaledSystem(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.flexible())], spacing: 16) {
                                    ForEach(Array(favoriteThemes.enumerated()), id: \.element.id) { index, theme in
                                        MeditationThemeCard(
                                            theme: theme,
                                            sessionStore: sessionStore,
                                            journalStore: journalStore,
                                            favoritesManager: favoritesManager,
                                            achievementsManager: achievementsManager,
                                            backgroundSoundManager: backgroundSoundManager
                                        )
                                        .frame(width: 160)
                                        .opacity(showContent ? 1.0 : 0.0)
                                        .scaleEffect(showContent ? 1.0 : 0.8)
                                        .animation(
                                            .spring(response: 0.6, dampingFraction: 0.7)
                                            .delay(Double(index) * 0.05),
                                            value: showContent
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // All Meditations Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Meditations")
                            .font(.appScaledSystem(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(MeditationTheme.sampleThemes.enumerated()), id: \.element.id) { index, theme in
                                MeditationThemeCard(
                                    theme: theme,
                                    sessionStore: sessionStore,
                                    journalStore: journalStore,
                                    favoritesManager: favoritesManager,
                                    achievementsManager: achievementsManager,
                                    backgroundSoundManager: backgroundSoundManager
                                )
                                .opacity(showContent ? 1.0 : 0.0)
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.08),
                                    value: showContent
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Progress & Journal — liquid glass pills at bottom
                    HStack(spacing: 12) {
                        NavigationLink(destination: ProgressView(sessionStore: sessionStore)) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.48, green: 0.38, blue: 1.0).opacity(0.9))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "chart.bar.fill")
                                        .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Progress")
                                    .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background {
                                LiquidGlassCardBackground(isDark: isHomeDark, cornerRadius: HomeGlass.pillRadius)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: JournalView(journalStore: journalStore, sessionStore: sessionStore)) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.58, blue: 0.22).opacity(0.95))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "book.fill")
                                        .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Journal")
                                    .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(HomeGlass.primaryText(isDark: isHomeDark))
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background {
                                LiquidGlassCardBackground(isDark: isHomeDark, cornerRadius: HomeGlass.pillRadius)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.001))
            }
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(red: 0.435, green: 0.525, blue: 0.839), Color(red: 0.282, green: 0.776, blue: 0.937)]
                        : [Color(red: 0.357, green: 0.643, blue: 0.902), Color(red: 0.220, green: 0.639, blue: 0.647)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Home Reminder Tip Card

private struct HomeReminderTipCard: View {
    let isDark: Bool
    let onEnable: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "bell.badge.fill")
                .font(.appScaledSystem(size: 22, design: .rounded))
                .foregroundStyle(Color(red: 0.45, green: 0.72, blue: 1.0))

            VStack(alignment: .leading, spacing: 10) {
                Text("Build a daily habit")
                    .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(HomeGlass.primaryText(isDark: isDark))

                Text("Turn on a gentle daily reminder in Settings — or tap below to enable now.")
                    .font(.appScaledSystem(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onEnable) {
                    Text("Turn On Reminders")
                        .font(.appScaledSystem(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color(red: 0.35, green: 0.62, blue: 0.95))
                        }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 8)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.appScaledSystem(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                    .frame(width: 30, height: 30)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay { Circle().fill(Color.black.opacity(isDark ? 0.25 : 0.06)) }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background {
            LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
        }
    }
}

// MARK: - Home Streak Card

private struct HomeStreakCard: View {
    let currentStreak: Int
    let isDark: Bool

    private var streakAccent: Color {
        isDark ? Color(red: 1.0, green: 0.62, blue: 0.22) : Color(red: 0.95, green: 0.45, blue: 0.1)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(streakAccent.opacity(isDark ? 0.35 : 0.22))
                    .frame(width: 48, height: 48)
                Image(systemName: "flame.fill")
                    .font(.appScaledSystem(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(streakAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(currentStreak == 0 ? "Start your streak today" : "\(currentStreak) Day Streak")
                    .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(HomeGlass.primaryText(isDark: isDark))

                Text(currentStreak == 0 ? "Complete a session to begin" : "Keep the momentum going!")
                    .font(.appScaledSystem(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.appScaledSystem(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay { Circle().fill(Color.black.opacity(isDark ? 0.28 : 0.05)) }
                        .overlay { Circle().stroke(Color.white.opacity(isDark ? 0.12 : 0.4), lineWidth: 1) }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(currentStreak == 0 ? "Start your streak today" : "\(currentStreak) day streak")
        .accessibilityHint("Double tap to view your progress")
    }
}

// MARK: - Meditation Theme Card

struct MeditationThemeCard: View {
    let theme: MeditationTheme
    let sessionStore: SessionStore
    let journalStore: JournalStore
    let favoritesManager: FavoritesManager
    let achievementsManager: AchievementsManager
    let backgroundSoundManager: BackgroundSoundManager
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isFavorite: Bool {
        favoritesManager.isFavorite(theme.name)
    }
    
    private var isDark: Bool { colorScheme == .dark }
    private var accent: Color { homeIconColor(for: theme.color, isDark: isDark) }
    
    var body: some View {
        NavigationLink(destination: MeditationDetailsView(
            theme: theme,
            sessionStore: sessionStore,
            journalStore: journalStore,
            achievementsManager: achievementsManager,
            backgroundSoundManager: backgroundSoundManager
        )) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    ThemeIconBloom(
                        color: accent,
                        systemName: theme.iconName,
                        iconFontSize: 26,
                        circleDiameter: 56,
                        isDark: isDark
                    )
                    
                    VStack(spacing: 6) {
                        Text(theme.name)
                            .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(HomeGlass.primaryText(isDark: isDark))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .frame(height: 44, alignment: .center)
                        
                        Text(theme.description)
                            .font(.appScaledSystem(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 32, alignment: .top)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 14)
                .background {
                    LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
                }
                
                Button(action: {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoritesManager.toggleFavorite(theme.name)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 34, height: 34)
                            .overlay {
                                Circle()
                                    .fill(Color.black.opacity(isDark ? 0.35 : 0.06))
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.white.opacity(isDark ? 0.14 : 0.4), lineWidth: 1)
                            }
                        
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.appScaledSystem(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(isFavorite ? Color(red: 1.0, green: 0.86, blue: 0.2) : HomeGlass.secondaryText(isDark: isDark))
                            .scaleEffect(isFavorite ? 1.08 : 1.0)
                    }
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                .accessibilityHint("Double tap to \(isFavorite ? "remove" : "add") \(theme.name) meditation \(isFavorite ? "from" : "to") favorites")
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        .buttonStyle(SpringScaleButtonStyle())
    }
}

// MARK: - Quick Breathing Card

struct QuickBreathingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    private var breathAccent: Color {
        isDark ? Color(red: 0.45, green: 0.92, blue: 0.95) : Color(red: 0.0, green: 0.52, blue: 0.62)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ThemeIconBloom(
                color: breathAccent,
                systemName: "wind",
                iconFontSize: 24,
                circleDiameter: 54,
                isDark: isDark
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Quick Breathing")
                    .font(.appScaledSystem(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(HomeGlass.primaryText(isDark: isDark))
                
                Text("1-3 minute calm reset")
                    .font(.appScaledSystem(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
            }
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.appScaledSystem(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(HomeGlass.primaryText(isDark: isDark))
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay { Circle().fill(Color.black.opacity(isDark ? 0.32 : 0.05)) }
                        .overlay { Circle().stroke(Color.white.opacity(isDark ? 0.12 : 0.45), lineWidth: 1) }
                }
        }
        .padding(20)
        .background {
            LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
        }
    }
}

// MARK: - Recently Played Card

struct RecentlyPlayedCard: View {
    let session: MeditationSession
    let theme: MeditationTheme
    let sessionStore: SessionStore
    let journalStore: JournalStore
    let favoritesManager: FavoritesManager
    let achievementsManager: AchievementsManager
    let backgroundSoundManager: BackgroundSoundManager
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    private var accent: Color { homeIconColor(for: theme.color, isDark: isDark) }
    
    private var sessionSubtitle: String {
        let ds = session.date.formatted(.dateTime.month(.abbreviated).day())
        return "\(ds) • \(session.duration) min"
    }
    
    var body: some View {
        NavigationLink(destination: MeditationDetailsView(
            theme: theme,
            sessionStore: sessionStore,
            journalStore: journalStore,
            achievementsManager: achievementsManager,
            backgroundSoundManager: backgroundSoundManager
        )) {
            HStack(spacing: 16) {
                ThemeIconBloom(
                    color: accent,
                    systemName: theme.iconName,
                    iconFontSize: 24,
                    circleDiameter: 54,
                    isDark: isDark
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(theme.name)
                        .font(.appScaledSystem(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(HomeGlass.primaryText(isDark: isDark))
                    
                    Text(sessionSubtitle)
                        .font(.appScaledSystem(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                }
                
                Spacer(minLength: 8)
                
                ZStack {
                    Circle()
                        .fill(accent)
                        .frame(width: 44, height: 44)
                        .shadow(color: accent.opacity(0.45), radius: 8, x: 0, y: 4)
                    Image(systemName: "play.fill")
                        .font(.appScaledSystem(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(x: 2)
                }
            }
            .padding(20)
            .background {
                LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
            }
        }
        .buttonStyle(SpringScaleButtonStyle())
    }
}

struct RecentlyPlayedBreathingCard: View {
    let session: MeditationSession
    let sessionStore: SessionStore
    let achievementsManager: AchievementsManager

    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }
    private var accent: Color { homeIconColor(for: session.themeColor, isDark: isDark) }

    private var sessionSubtitle: String {
        let ds = session.date.formatted(.dateTime.month(.abbreviated).day())
        return "\(ds) • \(session.duration) min"
    }

    var body: some View {
        NavigationLink(destination: BreathingExerciseView(
            sessionStore: sessionStore,
            achievementsManager: achievementsManager
        )) {
            HStack(spacing: 16) {
                ThemeIconBloom(
                    color: accent,
                    systemName: session.themeIcon,
                    iconFontSize: 24,
                    circleDiameter: 54,
                    isDark: isDark
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(session.themeName)
                        .font(.appScaledSystem(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(HomeGlass.primaryText(isDark: isDark))

                    Text(sessionSubtitle)
                        .font(.appScaledSystem(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(HomeGlass.secondaryText(isDark: isDark))
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(accent)
                        .frame(width: 44, height: 44)
                        .shadow(color: accent.opacity(0.45), radius: 8, x: 0, y: 4)
                    Image(systemName: "play.fill")
                        .font(.appScaledSystem(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(x: 2)
                }
            }
            .padding(20)
            .background {
                LiquidGlassCardBackground(isDark: isDark, cornerRadius: HomeGlass.cardRadius)
            }
        }
        .buttonStyle(SpringScaleButtonStyle())
    }
}

#Preview {
    ContentView()
}
