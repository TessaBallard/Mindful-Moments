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
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Mindfulness"
        content.body = "Take a moment to pause, breathe, and find your calm."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyMeditationReminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Daily reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMeditationReminder"])
        print("🔕 Daily reminder cancelled")
    }
}
