//
//  AchievementCelebrationView.swift
//  Mindful Moments
//
//  Achievement unlock celebration overlay
//

import SwiftUI

struct AchievementCelebrationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var confettiTrigger = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        onDismiss()
                    }
                }
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.3),
                                        Color.yellow.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: achievement.iconName)
                            .font(.system(size: 72, design: .rounded))
                            .foregroundStyle(.yellow)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .rotationEffect(.degrees(showContent ? 0 : -180))
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContent)
                    
                    VStack(spacing: 12) {
                        Text("Achievement Unlocked!")
                            .font(.brandLargeTitle)
                            .foregroundStyle(.primary)
                        
                        Text(achievement.title)
                            .font(.brandTitle2)
                            .foregroundStyle(.yellow)
                        
                        Text(achievement.description)
                            .font(.brandHeadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                }
                .padding(40)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.5),
                                        Color.yellow.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                }
                .cornerRadius(32)
                .shadow(color: .yellow.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 40)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)
                
                Button(action: {
                    HapticManager.medium()
                    withAnimation {
                        onDismiss()
                    }
                }) {
                    Text("Continue")
                        .font(.brandHeadline)
                        .foregroundStyle(.white)
                        .frame(width: 200)
                        .padding(.vertical, 16)
                        .background(.cyan)
                        .cornerRadius(16)
                        .shadow(color: .cyan.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showContent)
                
                Spacer()
            }
            
            ForEach(0..<40) { _ in
                ConfettiParticle()
                    .id(confettiTrigger)
            }
        }
        .onAppear {
            HapticManager.success()
            showContent = true
            confettiTrigger += 1
        }
    }
}

#Preview {
    AchievementCelebrationView(
        achievement: Achievement.allAchievements[0],
        onDismiss: {}
    )
}
