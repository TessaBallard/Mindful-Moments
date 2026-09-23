//
//  MeditationTheme.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import SwiftUI

/// Model representing a meditation theme with its properties
struct MeditationTheme: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: String
    let iconName: String
    let description: String
    let benefits: [String]
    let availableDurations: [Int]
    var isPlusOnly: Bool = false

    static func theme(named name: String) -> MeditationTheme? {
        allThemes.first { $0.name == name }
    }

    static var allThemes: [MeditationTheme] {
        sampleThemes + plusThemes
    }

    static let sampleThemes: [MeditationTheme] = [
        MeditationTheme(
            name: "Calm",
            color: "mint",
            iconName: "leaf.fill",
            description: "Find inner peace and tranquility",
            benefits: [
                "Reduces stress and anxiety",
                "Promotes emotional balance",
                "Improves focus and clarity",
                "Enhances overall well-being"
            ],
            availableDurations: [5, 10, 15]
        ),
        MeditationTheme(
            name: "Sleep",
            color: "indigo",
            iconName: "moon.stars.fill",
            description: "Drift into peaceful slumber",
            benefits: [
                "Calms racing thoughts",
                "Relaxes body and mind",
                "Improves sleep quality",
                "Establishes bedtime routine"
            ],
            availableDurations: [5, 10, 15]
        ),
        MeditationTheme(
            name: "Focus",
            color: "blue",
            iconName: "brain.head.profile",
            description: "Sharpen your concentration",
            benefits: [
                "Enhances concentration",
                "Reduces mental fog",
                "Boosts productivity",
                "Strengthens attention span"
            ],
            availableDurations: [5, 10, 15]
        ),
        MeditationTheme(
            name: "Stress Relief",
            color: "pink",
            iconName: "heart.fill",
            description: "Release tension and worry",
            benefits: [
                "Reduces physical tension",
                "Lowers stress hormones",
                "Promotes relaxation",
                "Improves emotional resilience"
            ],
            availableDurations: [5, 10, 15]
        ),
        MeditationTheme(
            name: "Energy",
            color: "orange",
            iconName: "bolt.fill",
            description: "Revitalize your mind and body",
            benefits: [
                "Boosts mental energy",
                "Increases motivation",
                "Enhances vitality",
                "Improves mood and outlook"
            ],
            availableDurations: [5, 10, 15]
        ),
        MeditationTheme(
            name: "Gratitude",
            color: "yellow",
            iconName: "sun.max.fill",
            description: "Cultivate appreciation and joy",
            benefits: [
                "Enhances positive emotions",
                "Improves relationships",
                "Increases life satisfaction",
                "Reduces negative thinking"
            ],
            availableDurations: [5, 10, 15]
        )
    ]

    static let plusThemes: [MeditationTheme] = [
        MeditationTheme(
            name: "Self-Compassion",
            color: "rose",
            iconName: "heart.circle.fill",
            description: "Meet yourself with kindness",
            benefits: [
                "Softens self-criticism",
                "Builds emotional resilience",
                "Supports difficult moments",
                "Cultivates inner warmth"
            ],
            availableDurations: [5, 10, 15],
            isPlusOnly: true
        ),
        MeditationTheme(
            name: "Body Scan",
            color: "sage",
            iconName: "figure.mind.and.body",
            description: "Release tension body to mind",
            benefits: [
                "Increases body awareness",
                "Releases physical tension",
                "Calms the nervous system",
                "Deepens present-moment focus"
            ],
            availableDurations: [5, 10, 15],
            isPlusOnly: true
        )
    ]
}
