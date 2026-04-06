//
//  AchievementsManager.swift
//  Mindful Moments
//
//  Manages achievement unlocking and persistence
//

import Foundation
import Observation

@Observable
class AchievementsManager {
    private(set) var achievements: [Achievement] = Achievement.allAchievements
    var newlyUnlockedAchievements: [Achievement] = []
    
    private let storageKey = "unlockedAchievements"
    
    init() {
        loadAchievements()
    }
    
    /// Check for new achievements after a meditation session
    func checkForNewAchievements(sessionStore: SessionStore) -> [Achievement] {
        var newAchievements: [Achievement] = []
        
        let totalSessions = sessionStore.totalSessions
        let currentStreak = sessionStore.currentStreak
        let totalMinutes = sessionStore.totalMinutes
        let moodImprovedCount = sessionStore.sessions.filter { $0.hadMoodImprovement }.count
        
        // Get unique theme names from sessions
        let uniqueThemes = Set(sessionStore.sessions.map { $0.themeName })
        
        // Session milestones
        if totalSessions == 1 {
            newAchievements.append(contentsOf: unlockAchievement(id: "first_session"))
        }
        if totalSessions == 5 {
            newAchievements.append(contentsOf: unlockAchievement(id: "5_sessions"))
        }
        if totalSessions == 10 {
            newAchievements.append(contentsOf: unlockAchievement(id: "10_sessions"))
        }
        if totalSessions == 25 {
            newAchievements.append(contentsOf: unlockAchievement(id: "25_sessions"))
        }
        if totalSessions == 50 {
            newAchievements.append(contentsOf: unlockAchievement(id: "50_sessions"))
        }
        if totalSessions == 100 {
            newAchievements.append(contentsOf: unlockAchievement(id: "100_sessions"))
        }
        
        // Streak milestones
        if currentStreak == 2 {
            newAchievements.append(contentsOf: unlockAchievement(id: "early_riser"))
        }
        if currentStreak == 7 {
            newAchievements.append(contentsOf: unlockAchievement(id: "week_warrior"))
        }
        if currentStreak == 30 {
            newAchievements.append(contentsOf: unlockAchievement(id: "month_master"))
        }
        
        // Time milestone
        if totalMinutes >= 60 {
            newAchievements.append(contentsOf: unlockAchievement(id: "hour_club"))
        }
        
        // Mood improvement
        if moodImprovedCount >= 5 {
            newAchievements.append(contentsOf: unlockAchievement(id: "mood_master"))
        }
        
        // Theme exploration
        if uniqueThemes.count >= 3 {
            newAchievements.append(contentsOf: unlockAchievement(id: "theme_explorer"))
        }
        
        // Store newly unlocked for UI
        newlyUnlockedAchievements = newAchievements
        
        return newAchievements
    }
    
    /// Unlock a specific achievement
    private func unlockAchievement(id: String) -> [Achievement] {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else {
            return []
        }
        
        // Don't re-unlock
        guard !achievements[index].isUnlocked else {
            return []
        }
        
        achievements[index].isUnlocked = true
        saveAchievements()
        
        return [achievements[index]]
    }
    
    /// Clear newly unlocked achievements
    func clearNewlyUnlocked() {
        newlyUnlockedAchievements = []
    }
    
    /// Get count of unlocked achievements
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    /// Get percentage of achievements unlocked
    var completionPercentage: Int {
        guard !achievements.isEmpty else { return 0 }
        return Int((Double(unlockedCount) / Double(achievements.count)) * 100)
    }
    
    /// Save achievements to UserDefaults
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    /// Load achievements from UserDefaults
    private func loadAchievements() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Achievement].self, from: data) else {
            achievements = Achievement.allAchievements
            return
        }
        achievements = decoded
    }
}
