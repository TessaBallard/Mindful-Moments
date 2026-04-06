//
//  ProgressView.swift
//  Mindful Moments
//
//  Progress tracking and statistics screen
//

import SwiftUI

struct ProgressView: View {
    let sessionStore: SessionStore
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Streak Recovery Message (if applicable)
                if let message = sessionStore.streakRecoveryMessage {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.appScaledSystem(size: 24, design: .rounded))
                                .foregroundStyle(.orange)
                            
                            Text(message)
                                .font(.brandSubheadline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(20)
                        .background {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.15),
                                        Color.yellow.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                StreakBanner(currentStreak: sessionStore.currentStreak)
                    .padding(.horizontal)
                    .padding(.top, sessionStore.streakRecoveryMessage == nil ? 20 : 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Total Sessions",
                        value: "\(sessionStore.totalSessions)",
                        icon: "checkmark.circle.fill",
                        color: .mint
                    )
                    
                    StatCard(
                        title: "Total Minutes",
                        value: "\(sessionStore.totalMinutes)",
                        icon: "clock.fill",
                        color: .indigo
                    )
                }
                .padding(.horizontal)
                .padding(.top, sessionStore.streakRecoveryMessage == nil ? 8 : 0)
                
                if !sessionStore.sessions.isEmpty {
                    VStack(spacing: 16) {
                        WeeklyProgressChart(sessions: sessionStore.sessions)
                        
                        StatCard(
                            title: "Mood Improved",
                            value: "\(sessionStore.moodImprovementRate)%",
                            icon: "heart.fill",
                            color: .pink
                        )
                        
                        MoodTrendsChart(sessions: sessionStore.sessions)
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.appScaledSystem(size: 16, design: .rounded))
                            .foregroundStyle(.yellow)
                        
                        Text("Achievements")
                            .font(.brandTitle2)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: AchievementsListView(achievementsManager: AchievementsManager())) {
                        AchievementsPreview(achievementsManager: AchievementsManager())
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Sessions")
                        .font(.brandTitle2)
                        .padding(.horizontal)
                    
                    if sessionStore.sessions.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(Array(sessionStore.sessions.prefix(20).enumerated()), id: \.element.id) { index, session in
                            SessionCard(session: session)
                                .padding(.horizontal)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: sessionStore.sessions)
                        }
                        
                        if sessionStore.sessions.count > 20 {
                            Text("Showing 20 most recent of \(sessionStore.sessions.count) sessions")
                                .font(.brandCaption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Progress")
                    .font(.brandLargeTitle)
                    .foregroundStyle(.primary)
            }
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.122, green: 0.102, blue: 0.306), Color(red: 0.380, green: 0.333, blue: 0.961)]
                    : [Color(red: 0.000, green: 0.784, blue: 0.702), Color(red: 0.600, green: 0.902, blue: 0.871)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Supporting Views

struct StreakBanner: View {
    let currentStreak: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.orange.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: "flame.fill")
                    .font(.appScaledSystem(size: 28, design: .rounded))
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(currentStreak) Day Streak")
                    .font(.brandTitle2)
                    .foregroundStyle(.primary)
                
                Text(currentStreak == 0 ? "Start your journey today" : "Keep the momentum going!")
                    .font(.brandCaption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.orange.opacity(colorScheme == .dark ? 0.12 : 0.08),
                        Color.orange.opacity(colorScheme == .dark ? 0.08 : 0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 4)
        .shadow(color: Color.orange.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.appScaledSystem(size: 28, design: .rounded))
                .foregroundStyle(color)
            
            Text(value)
                .font(.appScaledSystem(size: 24, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.85)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.brandCaption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        color.opacity(colorScheme == .dark ? 0.12 : 0.08),
                        color.opacity(colorScheme == .dark ? 0.08 : 0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 4)
        .shadow(color: color.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct SessionCard: View {
    let session: MeditationSession
    @Environment(\.colorScheme) private var colorScheme
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: session.themeIcon)
                .font(.appScaledSystem(size: 24, design: .rounded))
                .foregroundStyle(colorForTheme(session.themeColor))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(colorForTheme(session.themeColor).opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.themeName)
                    .font(.brandHeadline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Text("\(session.duration) min")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                    
                    if session.moodBefore != nil && session.moodAfter != nil {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text("Mood tracked")
                            .font(.brandCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(formattedDate)
                    .font(.appScaledSystem(size: 11, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            if session.hadMoodImprovement {
                Image(systemName: "arrow.up.heart.fill")
                    .font(.appScaledSystem(size: 20, design: .rounded))
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
            }
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
    }
    
    private func colorForTheme(_ colorName: String) -> Color {
        switch colorName {
        case "mint": return .mint
        case "indigo": return .indigo
        case "blue": return .blue
        case "pink": return .pink
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .primary
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.appScaledSystem(size: 48, design: .rounded))
                .foregroundStyle(.secondary)
            
            Text("No sessions yet")
                .font(.brandTitle2)
                .foregroundStyle(.primary)
            
            Text("Complete your first meditation to see your progress here")
                .font(.brandSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
}

struct AchievementsPreview: View {
    let achievementsManager: AchievementsManager
    @Environment(\.colorScheme) private var colorScheme
    
    private var displayedAchievements: [Achievement] {
        Array(achievementsManager.achievements.prefix(6))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(achievementsManager.unlockedCount) of \(achievementsManager.achievements.count) Unlocked")
                        .font(.brandHeadline)
                        .foregroundStyle(.primary)
                    
                    Text("\(achievementsManager.completionPercentage)% Complete")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.appScaledSystem(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(displayedAchievements) { achievement in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: achievement.iconName)
                                .font(.appScaledSystem(size: 24, design: .rounded))
                                .foregroundStyle(achievement.isUnlocked ? .yellow : .secondary)
                        }
                        
                        Text(achievement.title)
                            .font(.appScaledSystem(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
            }
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct AchievementsListView: View {
    let achievementsManager: AchievementsManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(achievementsManager.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.122, green: 0.102, blue: 0.306), Color(red: 0.380, green: 0.333, blue: 0.961)]
                    : [Color(red: 0.000, green: 0.784, blue: 0.702), Color(red: 0.600, green: 0.902, blue: 0.871)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 72, height: 72)
                
                Image(systemName: achievement.iconName)
                    .font(.appScaledSystem(size: 32, design: .rounded))
                    .foregroundStyle(achievement.isUnlocked ? .yellow : .secondary)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.brandHeadline)
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.brandCaption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.requirement)
                    .font(.appScaledSystem(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
            }
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        ProgressView(sessionStore: SessionStore())
    }
}
