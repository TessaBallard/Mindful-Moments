//
//  ReminderSettings.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation

/// D-004 — Reminder Settings
struct ReminderSettings: Codable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int
    
    init(isEnabled: Bool = false, hour: Int = 9, minute: Int = 0) {
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
}

