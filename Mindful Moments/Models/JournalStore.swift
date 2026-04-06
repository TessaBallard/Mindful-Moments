//
//  JournalStore.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation

/// Store for persisting journal entries
@Observable
class JournalStore {
    var entries: [JournalEntry] = []
    
    private let entriesKey = "savedJournalEntries"
    
    init() {
        loadEntries()
    }
    
    /// Add a new journal entry
    func addEntry(_ entry: JournalEntry) {
        entries.insert(entry, at: 0) // Add to beginning (most recent first)
        saveEntries()
    }
    
    /// Delete a journal entry
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    /// Save entries to UserDefaults
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    /// Load entries from UserDefaults
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else {
            entries = []
            return
        }
        entries = decoded
    }
}

