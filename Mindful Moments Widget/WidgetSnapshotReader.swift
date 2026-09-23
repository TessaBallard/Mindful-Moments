//
//  WidgetSnapshotReader.swift
//  Mindful Moments Widget
//

import Foundation

enum StreakWidgetKind {
    static let identifier = "StreakWidget"
}

enum WidgetSnapshotReader {
    static let appGroupID = "group.com.tessaballard.Mindful-Moments"
    static let snapshotKey = "widgetSnapshot"

    struct Snapshot: Codable {
        var currentStreak: Int
        var meditatedToday: Bool
        var totalMinutes: Int
        var lastUpdated: Date
    }

    static var current: Snapshot {
        guard
            let data = UserDefaults(suiteName: appGroupID)?.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else {
            return Snapshot(
                currentStreak: 0,
                meditatedToday: false,
                totalMinutes: 0,
                lastUpdated: Date()
            )
        }
        return snapshot
    }
}
