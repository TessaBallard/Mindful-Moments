//
//  SessionStore.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation

/// Store for persisting meditation sessions
@Observable
class SessionStore {
    var sessions: [MeditationSession] = []
    
    private let sessionsKey = "savedMeditationSessions"
    private let lastStreakKey = "lastKnownStreak"
    private let streakBrokenDateKey = "streakBrokenDate"
    
    /// Track the last known streak for motivational messages
    var lastKnownStreak: Int {
        get { UserDefaults.standard.integer(forKey: lastStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastStreakKey) }
    }
    
    /// Track when streak was broken for motivational messages
    var streakBrokenDate: Date? {
        get { UserDefaults.standard.object(forKey: streakBrokenDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: streakBrokenDateKey) }
    }
    
    init() {
        loadSessions()
        WidgetSnapshotStore.sync(from: self)
    }
    
    /// Add a new session
    func addSession(_ session: MeditationSession) {
        sessions.insert(session, at: 0) // Add to beginning (most recent first)
        saveSessions()
    }
    
    /// Get total meditation time in minutes
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    /// Get total number of sessions
    var totalSessions: Int {
        sessions.count
    }
    
    /// Get sessions from the last 7 days
    var recentSessions: [MeditationSession] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= sevenDaysAgo }
    }
    
    /// Calculate current meditation streak (consecutive days)
    var currentStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get unique meditation days (sorted newest first)
        var meditationDays = Set<Date>()
        for session in sessions {
            let day = calendar.startOfDay(for: session.date)
            meditationDays.insert(day)
        }
        
        let sortedDays = meditationDays.sorted(by: >)
        
        // Check if user meditated today or yesterday (streak is active)
        guard let mostRecentDay = sortedDays.first else { return 0 }
        let daysSinceLastMeditation = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0
        
        // Streak broken if more than 1 day gap
        if daysSinceLastMeditation > 1 {
            // Track the broken streak for motivational message
            if lastKnownStreak > 0 && streakBrokenDate == nil {
                streakBrokenDate = today
            }
            return 0
        }
        
        // Count consecutive days backwards from most recent
        var streak = 1
        var currentDay = mostRecentDay
        
        for i in 1..<sortedDays.count {
            let previousDay = sortedDays[i]
            let daysDifference = calendar.dateComponents([.day], from: previousDay, to: currentDay).day ?? 0
            
            // If exactly 1 day apart, streak continues
            if daysDifference == 1 {
                streak += 1
                currentDay = previousDay
            } else {
                // Gap in streak, stop counting
                break
            }
        }
        
        // Update last known streak if we have an active streak
        if streak > 0 {
            lastKnownStreak = streak
            streakBrokenDate = nil // Clear broken date when streak is active
        }
        
        return streak
    }

    /// Streak count after completing a session today, before `addSession` is called.
    var projectedStreakAfterSessionToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var meditationDays = Set<Date>()
        for session in sessions {
            meditationDays.insert(calendar.startOfDay(for: session.date))
        }

        if meditationDays.contains(today) {
            return currentStreak
        }

        if meditationDays.isEmpty {
            return 1
        }

        let sortedDays = meditationDays.sorted(by: >)
        guard let mostRecentDay = sortedDays.first else { return 1 }

        let daysSinceLastMeditation = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0

        if daysSinceLastMeditation > 1 {
            return 1
        }

        if daysSinceLastMeditation == 1 {
            return currentStreak + 1
        }

        return max(currentStreak, 1)
    }
    
    /// Get percentage of sessions that improved mood
    var moodImprovementRate: Int {
        let sessionsWithBothMoods = sessions.filter { $0.moodBefore != nil && $0.moodAfter != nil }
        guard !sessionsWithBothMoods.isEmpty else { return 0 }
        
        let improvedSessions = sessionsWithBothMoods.filter { $0.hadMoodImprovement }
        return Int((Double(improvedSessions.count) / Double(sessionsWithBothMoods.count)) * 100)
    }
    
    /// Get count of sessions with mood data
    var sessionsWithMoodData: Int {
        sessions.filter { $0.moodBefore != nil && $0.moodAfter != nil }.count
    }
    
    /// Get most common mood before meditation
    var mostCommonMoodBefore: Mood? {
        let moods = sessions.compactMap { $0.moodBefore }
        guard !moods.isEmpty else { return nil }
        
        let moodCounts = Dictionary(grouping: moods) { $0 }
        return moodCounts.max { $0.value.count < $1.value.count }?.key
    }
    
    /// Get most common mood after meditation
    var mostCommonMoodAfter: Mood? {
        let moods = sessions.compactMap { $0.moodAfter }
        guard !moods.isEmpty else { return nil }
        
        let moodCounts = Dictionary(grouping: moods) { $0 }
        return moodCounts.max { $0.value.count < $1.value.count }?.key
    }
    
    /// Get the most recently completed meditation session
    var mostRecentSession: MeditationSession? {
        sessions.first
    }
    
    /// Get motivational message if streak was recently broken
    var streakRecoveryMessage: String? {
        guard currentStreak == 0,
              let brokenDate = streakBrokenDate,
              lastKnownStreak > 0 else {
            return nil
        }
        
        let calendar = Calendar.current
        let daysSinceBroken = calendar.dateComponents([.day], from: brokenDate, to: Date()).day ?? 0
        
        // Only show recovery message for first 3 days after break
        guard daysSinceBroken <= 3 else { return nil }
        
        if lastKnownStreak >= 30 {
            return "You had an amazing \(lastKnownStreak)-day streak! Every journey has bumps - start fresh today. 🌟"
        } else if lastKnownStreak >= 14 {
            return "Your \(lastKnownStreak)-day streak was impressive! One day doesn't define you. Begin again. 💪"
        } else if lastKnownStreak >= 7 {
            return "You built a \(lastKnownStreak)-day streak! That shows commitment. Ready for a new start? ✨"
        } else {
            return "Starting fresh is part of the journey. Your next streak begins with this session. 🌱"
        }
    }
    
    /// Save sessions to UserDefaults
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        WidgetSnapshotStore.sync(from: self)
    }
    
    /// Load sessions from UserDefaults
    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let decoded = try? JSONDecoder().decode([MeditationSession].self, from: data) else {
            sessions = []
            return
        }
        sessions = decoded
    }
}
