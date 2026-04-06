//
//  Mindful_MomentsApp.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import SwiftUI

@main
struct Mindful_MomentsApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                ContentView()
            } else {
                WelcomeView()
            }
        }
    }
}
