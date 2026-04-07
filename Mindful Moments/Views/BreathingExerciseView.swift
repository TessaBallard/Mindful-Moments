//
//  BreathingExerciseView.swift
//  Mindful Moments
//
//  Quick breathing exercise feature
//

import SwiftUI

struct BreathingExerciseView: View {
    @State private var selectedDuration = 1
    @State private var isExercising = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathCount = 0
    @State private var exerciseStartDate: Date?
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    enum BreathPhase {
        case inhale, hold, exhale, rest
        
        var text: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .rest: return "Rest"
            }
        }
        
        var duration: TimeInterval {
            switch self {
            case .inhale: return 4.0
            case .hold: return 2.0
            case .exhale: return 6.0
            case .rest: return 2.0
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: MeditationScreenGradients.quickBreathingColors(isDark: colorScheme == .dark),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if !isExercising {
                setupScreen
            } else {
                breathingScreen
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var setupScreen: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.3),
                                    Color.cyan.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "wind")
                        .font(.appScaledSystem(size: 56, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? Color(red: 0.400, green: 0.900, blue: 0.900) : Color(red: 0.000, green: 0.500, blue: 0.550))
                }
                
                Text("Quick Breathing")
                    .font(.brandLargeTitle)
                    .foregroundStyle(.primary)
                
                Text("Follow the guided breathing pattern")
                    .font(.brandSubheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .scaleEffect(showContent ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)
            
            VStack(spacing: 16) {
                Text("Duration")
                    .font(.brandTitle3)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    ForEach([1, 2, 3], id: \.self) { duration in
                        Button(action: {
                            HapticManager.selection()
                            selectedDuration = duration
                        }) {
                            VStack(spacing: 4) {
                                Text("\(duration)")
                                    .font(.brandDurationDigit)
                                Text("MIN")
                                    .font(.brandDurationMinLabel)
                                    .tracking(0.6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(selectedDuration == duration ? Color.cyan : Color.cyan.opacity(0.2))
                            }
                            .foregroundStyle(selectedDuration == duration ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(
                                color: .black.opacity(selectedDuration == duration ? 0.12 : 0.06),
                                radius: 8,
                                x: 0,
                                y: 3
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.black.opacity(selectedDuration == duration ? 0 : 0.06), lineWidth: 1)
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: selectedDuration)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 40)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)
            
            Button(action: {
                HapticManager.medium()
                startExercise()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                    Text("Start Breathing")
                        .font(.brandHeadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.cyan)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: Color.cyan.opacity(0.35), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .buttonStyle(.plain)
            .accessibilityLabel("Start breathing exercise")
            .accessibilityHint("Double tap to begin \(selectedDuration) minute breathing exercise")
        }
    }
    
    private var breathingScreen: some View {
        VStack(spacing: 60) {
            Spacer()
            
            VStack(spacing: 8) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(sessionCountdownString(at: context.date))
                        .font(.brandTimer)
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                
                Text("Time remaining")
                    .font(.brandCaption)
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(0.4),
                                Color.cyan.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(breathPhase == .inhale ? 1.2 : breathPhase == .exhale ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: breathPhase.duration), value: breathPhase)
                
                VStack(spacing: 8) {
                    Text(breathPhase.text)
                        .font(.brandLargeTitle)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .font(.brandHeadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.cyan)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: Color.cyan.opacity(0.35), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .buttonStyle(.plain)
        }
    }
    
    private func sessionCountdownString(at date: Date) -> String {
        let totalSeconds = selectedDuration * 60
        guard let start = exerciseStartDate else {
            let m = totalSeconds / 60
            let s = totalSeconds % 60
            return "\(m):\(String(format: "%02d", s))"
        }
        let elapsed = Int(date.timeIntervalSince(start))
        let remaining = max(0, totalSeconds - elapsed)
        let m = remaining / 60
        let s = remaining % 60
        return "\(m):\(String(format: "%02d", s))"
    }
    
    private func startExercise() {
        exerciseStartDate = Date()
        isExercising = true
        breathCount = selectedDuration * 4
        cycleBreath()
    }
    
    private func cycleBreath() {
        guard breathCount > 0 else {
            completeExercise()
            return
        }
        
        breathPhase = .inhale
        DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
            breathPhase = .hold
            DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                breathPhase = .exhale
                DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                    breathPhase = .rest
                    breathCount -= 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                        cycleBreath()
                    }
                }
            }
        }
    }
    
    private func completeExercise() {
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    BreathingExerciseView()
}
