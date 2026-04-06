//
//  FavoritesManager.swift
//  Mindful Moments
//
//  Manages favorite meditation themes
//

import Foundation
import Observation

@Observable
class FavoritesManager {
    private(set) var favoriteThemeNames: Set<String> = []
    private let storageKey = "favoriteThemes"
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(_ themeName: String) -> Bool {
        favoriteThemeNames.contains(themeName)
    }
    
    func toggleFavorite(_ themeName: String) {
        if favoriteThemeNames.contains(themeName) {
            favoriteThemeNames.remove(themeName)
        } else {
            favoriteThemeNames.insert(themeName)
        }
        saveFavorites()
    }
    
    func getFavorites(from themes: [MeditationTheme]) -> [MeditationTheme] {
        themes.filter { favoriteThemeNames.contains($0.name) }
    }
    
    private func saveFavorites() {
        let array = Array(favoriteThemeNames)
        UserDefaults.standard.set(array, forKey: storageKey)
    }
    
    private func loadFavorites() {
        if let array = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            favoriteThemeNames = Set(array)
        }
    }
}
