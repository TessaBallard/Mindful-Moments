//
//  Achievement.swift
//  Mindful Moments
//
//  Model for gamification achievements
//

import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let requirement: String
    var isUnlocked: Bool
    
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_session",
            title: "First Journey",
            description: "Complete your first meditation",
            iconName: "flag.fill",
            requirement: "Complete 1 session",
            isUnlocked: false
        ),
        Achievement(
            id: "early_riser",
            title: "Early Riser",
            description: "Meditate two days in a row",
            iconName: "sunrise.fill",
            requirement: "2-day streak",
            isUnlocked: false
        ),
        Achievement(
            id: "week_warrior",
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            iconName: "flame.fill",
            requirement: "7-day streak",
            isUnlocked: false
        ),
        Achievement(
            id: "month_master",
            title: "Month Master",
            description: "Achieve a 30-day streak",
            iconName: "star.fill",
            requirement: "30-day streak",
            isUnlocked: false
        ),
        Achievement(
            id: "5_sessions",
            title: "Committed",
            description: "Complete 5 meditation sessions",
            iconName: "checkmark.circle.fill",
            requirement: "Complete 5 sessions",
            isUnlocked: false
        ),
        Achievement(
            id: "10_sessions",
            title: "Dedicated",
            description: "Complete 10 meditation sessions",
            iconName: "hands.clap.fill",
            requirement: "Complete 10 sessions",
            isUnlocked: false
        ),
        Achievement(
            id: "25_sessions",
            title: "Mindful Explorer",
            description: "Complete 25 meditation sessions",
            iconName: "sparkles",
            requirement: "Complete 25 sessions",
            isUnlocked: false
        ),
        Achievement(
            id: "50_sessions",
            title: "Zen Master",
            description: "Complete 50 meditation sessions",
            iconName: "crown.fill",
            requirement: "Complete 50 sessions",
            isUnlocked: false
        ),
        Achievement(
            id: "100_sessions",
            title: "Enlightened",
            description: "Complete 100 meditation sessions",
            iconName: "trophy.fill",
            requirement: "Complete 100 sessions",
            isUnlocked: false
        ),
        Achievement(
            id: "mood_master",
            title: "Mood Master",
            description: "Track mood improvement in 5 sessions",
            iconName: "heart.circle.fill",
            requirement: "5 improved moods",
            isUnlocked: false
        ),
        Achievement(
            id: "theme_explorer",
            title: "Theme Explorer",
            description: "Try 3 different meditation themes",
            iconName: "map.fill",
            requirement: "Try 3 themes",
            isUnlocked: false
        ),
        Achievement(
            id: "hour_club",
            title: "Hour Club",
            description: "Meditate for 60 total minutes",
            iconName: "clock.fill",
            requirement: "60 minutes total",
            isUnlocked: false
        )
    ]
}
