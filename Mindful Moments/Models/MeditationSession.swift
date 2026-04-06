//
//  MeditationSession.swift
//  Mindful Moments
//
//  Model for a completed meditation session
//

import Foundation

struct MeditationSession: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let duration: Int
    let themeName: String
    let themeColor: String
    let themeIcon: String
    let moodBefore: Mood?
    let moodAfter: Mood?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: Int,
        themeName: String,
        themeColor: String,
        themeIcon: String,
        moodBefore: Mood? = nil,
        moodAfter: Mood? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.themeName = themeName
        self.themeColor = themeColor
        self.themeIcon = themeIcon
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
    }
    
    var hadMoodImprovement: Bool {
        guard let before = moodBefore, let after = moodAfter else { return false }
        return after.score > before.score
    }
    
    var moodChangeScore: Int {
        guard let before = moodBefore, let after = moodAfter else { return 0 }
        return after.score - before.score
    }
}
