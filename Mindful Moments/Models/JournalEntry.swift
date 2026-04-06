//
//  JournalEntry.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation

/// D-003 — Journal Entries
struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let text: String
    let themeName: String?
    let themeIcon: String?
    
    /// Body text (alias for UI that uses `content`)
    var content: String { text }
    
    init(id: UUID = UUID(), date: Date = Date(), text: String, themeName: String? = nil, themeIcon: String? = nil) {
        self.id = id
        self.date = date
        self.text = text
        self.themeName = themeName
        self.themeIcon = themeIcon
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var preview: String {
        let maxLength = 100
        if text.count <= maxLength {
            return text
        }
        return String(text.prefix(maxLength)) + "..."
    }
}

// Sample data for previews
extension JournalEntry {
    static let sampleEntries: [JournalEntry] = [
        JournalEntry(
            date: Date().addingTimeInterval(-86400 * 2),
            text: "Today's meditation helped me feel more centered. I noticed my mind wandering less than usual."
        ),
        JournalEntry(
            date: Date().addingTimeInterval(-86400),
            text: "Feeling grateful for this peaceful moment. The stress relief session was exactly what I needed after a busy day."
        ),
        JournalEntry(
            date: Date().addingTimeInterval(-3600),
            text: "My focus has improved significantly. I was able to concentrate on my breathing throughout the entire session."
        )
    ]
}

