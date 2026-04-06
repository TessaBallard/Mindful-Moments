//
//  CompletionCelebrationView.swift
//  Mindful Moments
//
//  Celebration screen shown when meditation completes
//

import SwiftUI

struct CompletionCelebrationView: View {
    let theme: MeditationTheme
    let duration: Int
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var confettiTrigger = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: MeditationScreenGradients.themeColors(themeName: theme.name, isDark: colorScheme == .dark),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.3),
                                            Color.green.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                        
                        Text("Meditation Complete!")
                            .font(.brandLargeTitle)
                            .foregroundStyle(.primary)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
                        
                        Text("You completed \(duration) minutes of \(theme.name) meditation")
                            .font(.brandHeadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)
                    }
                    
                    Spacer()
                }
                
                ForEach(0..<30) { _ in
                    ConfettiParticle(fallDistance: geometry.size.height + 100)
                        .id(confettiTrigger)
                }
            }
        }
        .onAppear {
            showContent = true
            confettiTrigger += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onDismiss()
            }
        }
    }
}

struct ConfettiParticle: View {
    let fallDistance: CGFloat
    
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    private let randomColor: Color
    private let randomX: CGFloat
    private let randomRotation: Double
    private let randomDelay: Double
    
    /// Pass container height + padding so confetti falls past the bottom without using `UIScreen.main`.
    init(fallDistance: CGFloat = 1000) {
        self.fallDistance = fallDistance
        randomColor = colors.randomElement() ?? .blue
        randomX = CGFloat.random(in: -150...150)
        randomRotation = Double.random(in: 0...720)
        randomDelay = Double.random(in: 0...0.5)
    }
    
    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: 8, height: 8)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0).delay(randomDelay)) {
                    yOffset = fallDistance
                    xOffset = randomX
                    rotation = randomRotation
                    opacity = 0
                }
            }
    }
}

#Preview {
    CompletionCelebrationView(
        theme: MeditationTheme.sampleThemes[0],
        duration: 5,
        onDismiss: {}
    )
}
