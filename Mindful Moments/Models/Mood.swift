//
//  Mood.swift
//  Mindful Moments
//
//  Model for tracking user mood before and after meditation
//

import SwiftUI

enum Mood: String, CaseIterable, Codable, Identifiable {
    case stressed = "Stressed"
    case anxious = "Anxious"
    case sad = "Sad"
    case restless = "Restless"
    case tired = "Tired"
    case neutral = "Neutral"
    case calm = "Calm"
    case peaceful = "Peaceful"
    case happy = "Happy"
    case energized = "Energized"
    case grateful = "Grateful"
    case joyful = "Joyful"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    /// Moods shown on the check-in grid (matches reference 2×4 layout).
    static let checkInMoods: [Mood] = [
        .stressed, .anxious, .sad, .tired,
        .neutral, .calm, .happy, .energized
    ]
    
    var emoji: String {
        switch self {
        case .stressed: return "😰"
        case .anxious: return "😟"
        case .sad: return "😔"
        case .restless: return "😣"
        case .tired: return "😴"
        case .neutral: return "😐"
        case .calm: return "😊"
        case .peaceful: return "☺️"
        case .happy: return "😄"
        case .energized: return "⚡"
        case .grateful: return "🙏"
        case .joyful: return "😊"
        }
    }
    
    var description: String {
        switch self {
        case .stressed: return "Overwhelmed, tense"
        case .anxious: return "Worried, nervous"
        case .sad: return "Down, low mood"
        case .restless: return "Unsettled"
        case .tired: return "Fatigued, sleepy"
        case .neutral: return "Okay, balanced"
        case .calm: return "Peaceful, relaxed"
        case .peaceful: return "Content"
        case .happy: return "Content, joyful"
        case .energized: return "Alert, motivated"
        case .grateful: return "Thankful"
        case .joyful: return "Happy"
        }
    }
    
    var color: Color {
        switch self {
        case .stressed: return .red
        case .anxious: return .orange
        case .sad: return .indigo
        case .restless: return .yellow
        case .tired: return .purple
        case .neutral: return .gray
        case .calm: return .cyan
        case .peaceful: return .mint
        case .happy: return .yellow
        case .energized: return .green
        case .grateful: return .pink
        case .joyful: return .yellow
        }
    }
    
    var score: Int {
        switch self {
        case .stressed: return 1
        case .anxious: return 2
        case .sad: return 3
        case .restless: return 3
        case .tired: return 4
        case .neutral: return 5
        case .calm: return 6
        case .peaceful: return 7
        case .happy: return 8
        case .energized: return 9
        case .grateful: return 10
        case .joyful: return 10
        }
    }
}
