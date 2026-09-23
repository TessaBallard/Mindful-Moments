//
//  WidgetSnapshotStore.swift
//  Mindful Moments
//
//  Writes streak data to the App Group for the home screen widget.
//

import Foundation
import WidgetKit

enum WidgetSnapshotStore {
    static let appGroupID = "group.com.tessaballard.Mindful-Moments"
    static let snapshotKey = "widgetSnapshot"

    struct Snapshot: Codable {
        var currentStreak: Int
        var meditatedToday: Bool
        var totalMinutes: Int
        var lastUpdated: Date
    }

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func sync(from sessionStore: SessionStore) {
        let calendar = Calendar.current
        let meditatedToday: Bool = {
            guard let recent = sessionStore.mostRecentSession else { return false }
            return calendar.isDateInToday(recent.date)
        }()

        let snapshot = Snapshot(
            currentStreak: sessionStore.currentStreak,
            meditatedToday: meditatedToday,
            totalMinutes: sessionStore.totalMinutes,
            lastUpdated: Date()
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        sharedDefaults?.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: StreakWidgetKind.identifier)
    }
}

enum StreakWidgetKind {
    static let identifier = "StreakWidget"
}
