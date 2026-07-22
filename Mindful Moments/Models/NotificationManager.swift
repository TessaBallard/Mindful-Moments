//
//  NotificationManager.swift
//  Mindful Moments
//
//  Manages daily meditation reminder notifications
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
    var isAuthorized = false

    private static let legacyReminderIdentifier = "dailyMeditationReminder"
    private static let reminderIdentifiers = (1...7).map { "dailyMeditationReminder-\($0)" }

    private static let reminderTitles = [
        "Time for Mindfulness",
        "A Moment for You",
        "Pause & Breathe",
        "Your Daily Reset",
        "Mindful Moments"
    ]

    private static let reminderBodies = [
        "Take a moment to pause, breathe, and find your calm.",
        "Your daily pause awaits — even a few minutes can help.",
        "Step away for a breath. You deserve this quiet moment.",
        "A gentle reminder to slow down and check in with yourself.",
        "Build your streak with a quick meditation or breathing break."
    ]

    init() {
        checkAuthorization()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleDailyReminder(at time: Date) async {
        if !isAuthorized {
            guard await requestAuthorization() else { return }
        }

        cancelDailyReminder()

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        for weekday in 1...7 {
            let messageIndex = (weekday - 1) % Self.reminderBodies.count

            let content = UNMutableNotificationContent()
            content.title = Self.reminderTitles[messageIndex]
            content.body = Self.reminderBodies[messageIndex]
            content.sound = .default

            var components = DateComponents()
            components.weekday = weekday
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: Self.reminderIdentifiers[weekday - 1],
                content: content,
                trigger: trigger
            )

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("❌ Error scheduling notification for weekday \(weekday): \(error)")
            }
        }

        print("✅ Daily reminders scheduled for \(timeComponents.hour ?? 0):\(String(format: "%02d", timeComponents.minute ?? 0))")
    }

    func cancelDailyReminder() {
        var identifiers = Self.reminderIdentifiers
        identifiers.append(Self.legacyReminderIdentifier)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 Daily reminders cancelled")
    }
}
