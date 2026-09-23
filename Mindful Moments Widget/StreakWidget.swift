//
//  StreakWidget.swift
//  Mindful Moments Widget
//

import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshotReader.Snapshot
}

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(
            date: Date(),
            snapshot: WidgetSnapshotReader.Snapshot(
                currentStreak: 3,
                meditatedToday: true,
                totalMinutes: 42,
                lastUpdated: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), snapshot: WidgetSnapshotReader.current))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let snapshot = WidgetSnapshotReader.current
        let entry = StreakEntry(date: Date(), snapshot: snapshot)

        let calendar = Calendar.current
        let startOfTomorrow = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )

        completion(Timeline(entries: [entry], policy: .after(startOfTomorrow)))
    }
}

struct StreakWidget: Widget {
    let kind: String = StreakWidgetKind.identifier

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackground()
                }
        }
        .configurationDisplayName("Mindful Streak")
        .description("See your meditation streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct WidgetBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.08, green: 0.14, blue: 0.18),
                    Color(red: 0.12, green: 0.22, blue: 0.26)
                ]
                : [
                    Color(red: 0.92, green: 0.98, blue: 0.99),
                    Color(red: 0.82, green: 0.95, blue: 0.97)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct StreakWidgetEntryView: View {
    let entry: StreakEntry

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var family

    private var streakAccent: Color {
        colorScheme == .dark
            ? Color(red: 1.0, green: 0.62, blue: 0.22)
            : Color(red: 0.95, green: 0.45, blue: 0.1)
    }

    private var tealAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.45, green: 0.92, blue: 0.95)
            : Color(red: 0.0, green: 0.52, blue: 0.62)
    }

    var body: some View {
        switch family {
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(tealAccent)
                Text("Mindful Moments")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(streakAccent)
                Text(streakNumberText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Text(streakSubtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(streakAccent.opacity(colorScheme == .dark ? 0.28 : 0.18))
                    .frame(width: 56, height: 56)
                Image(systemName: "flame.fill")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(streakAccent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(streakTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(streakSubtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if entry.snapshot.totalMinutes > 0 {
                    Text("\(entry.snapshot.totalMinutes) mindful minutes total")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(tealAccent)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var streakNumberText: String {
        entry.snapshot.currentStreak == 0 ? "0" : "\(entry.snapshot.currentStreak)"
    }

    private var streakTitle: String {
        if entry.snapshot.currentStreak == 0 {
            return "Start your streak"
        }
        return "\(entry.snapshot.currentStreak) Day Streak"
    }

    private var streakSubtitle: String {
        if entry.snapshot.currentStreak == 0 {
            return "Complete a session to begin"
        }
        if entry.snapshot.meditatedToday {
            return "You're showing up today — nice work!"
        }
        return "Complete a session today to keep it going"
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(
        date: Date(),
        snapshot: WidgetSnapshotReader.Snapshot(
            currentStreak: 5,
            meditatedToday: true,
            totalMinutes: 120,
            lastUpdated: Date()
        )
    )
}

#Preview(as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(
        date: Date(),
        snapshot: WidgetSnapshotReader.Snapshot(
            currentStreak: 5,
            meditatedToday: true,
            totalMinutes: 120,
            lastUpdated: Date()
        )
    )
}
