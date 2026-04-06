//
//  WelcomeView.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import SwiftUI

/// Welcome screen shown on first launch
struct WelcomeView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Custom welcome screen background (adapts to dark mode)
                if colorScheme == .dark {
                    Image("WelcomeScreenDark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .ignoresSafeArea()
                } else {
                    Image("WelcomeScreenLight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .ignoresSafeArea()
                }
                
                // Gradient overlay to ensure button visibility
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.clear,
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Get Started button
                    Button(action: {
                        HapticManager.medium()
                        hasSeenWelcome = true
                    }) {
                        Text("GET STARTED")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: geometry.size.width > 600 ? 400 : .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 0.9),
                                        Color(red: 0.3, green: 0.6, blue: 0.8)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                    .opacity(showContent ? 1.0 : 0.0)
                    .scaleEffect(showContent ? 1.0 : 0.9)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            showContent = true
        }
    }
}

#Preview {
    WelcomeView()
}

#Preview("Dark Mode") {
    WelcomeView()
        .preferredColorScheme(.dark)
}
