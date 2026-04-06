//
//  BackgroundSoundManager.swift
//  Mindful Moments
//
//  Manages background sound preferences
//

import Foundation
import Observation

@Observable
class BackgroundSoundManager {
    var selectedSound: BackgroundSound {
        didSet {
            saveSelection()
        }
    }
    
    private let storageKey = "selectedBackgroundSound"
    
    init() {
        // Load saved selection or default to river
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(BackgroundSound.self, from: savedData) {
            selectedSound = decoded
        } else {
            selectedSound = .river
        }
    }
    
    private func saveSelection() {
        if let encoded = try? JSONEncoder().encode(selectedSound) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
