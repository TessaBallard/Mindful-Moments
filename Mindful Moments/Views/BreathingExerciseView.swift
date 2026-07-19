//
//  BreathingExerciseView.swift
//  Mindful Moments
//
//  Quick breathing exercise feature
//

import SwiftUI
import AVFoundation

struct BreathingExerciseView: View {
    @State private var selectedDuration = 1
    @State private var isExercising = false
    @State private var isPaused = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var exerciseStartDate: Date?
    @State private var totalPausedDuration: TimeInterval = 0
    @State private var pauseStartDate: Date?
    @State private var showContent = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var silentLoopPlayer: AVAudioPlayer?
    @State private var exerciseTask: Task<Void, Never>?
    @AppStorage(VoicePreference.storageKey) private var guidedVoicePreference = VoicePreference.male.rawValue
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var voicePreference: VoicePreference {
        VoicePreference(rawValue: guidedVoicePreference) ?? .male
    }

    private var usesGuidedBreathingTrack: Bool {
        voicePreference == .female
    }

    private var centerPhaseText: String {
        if isPaused { return "Paused" }
        if usesGuidedBreathingTrack && isExercising { return "Follow Along" }
        return breathPhase.text
    }
    
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
        .onDisappear {
            exerciseTask?.cancel()
            exerciseTask = nil
            audioPlayer?.stop()
            audioPlayer = nil
            silentLoopPlayer?.stop()
            silentLoopPlayer = nil
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
                // Outer glow ring
                Circle()
                    .stroke(Color.cyan.opacity(colorScheme == .dark ? 0.35 : 0.25), lineWidth: 2)
                    .frame(width: 260, height: 260)
                    .scaleEffect(breathPhase == .inhale ? 1.2 : breathPhase == .exhale ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: breathPhase.duration), value: breathPhase)

                // Main filled circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(colorScheme == .dark ? 0.75 : 0.75),
                                Color.cyan.opacity(colorScheme == .dark ? 0.25 : 0.35)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 110
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.cyan.opacity(colorScheme == .dark ? 0.6 : 0.65), lineWidth: 1.5)
                    )
                    .shadow(color: Color.cyan.opacity(colorScheme == .dark ? 0.45 : 0.5), radius: 24, x: 0, y: 0)
                    .frame(width: 240, height: 240)
                    .scaleEffect(breathPhase == .inhale ? 1.2 : breathPhase == .exhale ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: breathPhase.duration), value: breathPhase)
                
                VStack(spacing: 8) {
                    Text(centerPhaseText)
                        .font(.brandLargeTitle)
                        .foregroundStyle(.primary)
                        .animation(.easeInOut(duration: 0.2), value: isPaused)
                }
            }
            
            Spacer()

            VStack(spacing: 14) {
                // Pause / Resume
                Button(action: {
                    HapticManager.selection()
                    if isPaused { resumeExercise() } else { pauseExercise() }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                        Text(isPaused ? "Resume" : "Pause")
                            .font(.brandHeadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.cyan.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(Color.cyan.opacity(0.45), lineWidth: 1.5)
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .buttonStyle(.plain)

                // End session
                Button(action: { dismiss() }) {
                    Text("End Session")
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
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
    
    private func sessionCountdownString(at date: Date) -> String {
        let totalSeconds = selectedDuration * 60
        guard let start = exerciseStartDate else {
            let m = totalSeconds / 60
            let s = totalSeconds % 60
            return "\(m):\(String(format: "%02d", s))"
        }
        // Subtract paused time so the countdown freezes while paused
        let currentPause = isPaused ? (pauseStartDate.map { date.timeIntervalSince($0) } ?? 0) : 0
        let effectiveElapsed = Int(date.timeIntervalSince(start) - totalPausedDuration - currentPause)
        let remaining = max(0, totalSeconds - effectiveElapsed)
        let m = remaining / 60
        let s = remaining % 60
        return "\(m):\(String(format: "%02d", s))"
    }
    
    /// Plays a looping silent audio buffer to keep the AVAudioSession active
    /// in the background so Swift async sleeps continue firing between cue clips.
    private func startSilentLoop() {
        let wav: [UInt8] = [
            0x52, 0x49, 0x46, 0x46, 0x26, 0x00, 0x00, 0x00,
            0x57, 0x41, 0x56, 0x45, 0x66, 0x6D, 0x74, 0x20,
            0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
            0x44, 0xAC, 0x00, 0x00, 0x88, 0x58, 0x01, 0x00,
            0x02, 0x00, 0x10, 0x00, 0x64, 0x61, 0x74, 0x61,
            0x02, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        guard let player = try? AVAudioPlayer(data: Data(wav)) else { return }
        player.numberOfLoops = -1
        player.volume = 0.001
        player.prepareToPlay()
        player.play()
        silentLoopPlayer = player
    }

    /// Sleeps for `seconds` of active (non-paused) time, polling every 0.1s.
    private func sleepWithPause(seconds: Double) async {
        var remaining = seconds
        while remaining > 0 {
            guard !Task.isCancelled else { return }
            if isPaused {
                try? await Task.sleep(nanoseconds: 100_000_000)
            } else {
                let slice = min(remaining, 0.1)
                try? await Task.sleep(nanoseconds: UInt64(slice * 1_000_000_000))
                remaining -= slice
            }
        }
    }

    private func pauseExercise() {
        isPaused = true
        pauseStartDate = Date()
        audioPlayer?.pause()
        silentLoopPlayer?.pause()
    }

    private func resumeExercise() {
        if let start = pauseStartDate {
            totalPausedDuration += Date().timeIntervalSince(start)
            pauseStartDate = nil
        }
        isPaused = false
        silentLoopPlayer?.play()
        audioPlayer?.play()
    }

    private func playBreathingCue(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // Audio unavailable — exercise continues silently
        }
    }

    private func startExercise() {
        exerciseStartDate = Date()
        isExercising = true

        if usesGuidedBreathingTrack {
            playGuidedBreathingTrack()
            exerciseTask = Task { @MainActor in
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await self.runGuidedTrackTimer() }
                    group.addTask { await self.runVisualBreathCycle() }
                }
            }
        } else {
            startSilentLoop()
            exerciseTask = Task { @MainActor in
                await runCueBasedExercise()
            }
        }
    }

    private func playGuidedBreathingTrack() {
        let fileName = VoicePreference.breathingVoiceFileName(duration: selectedDuration)
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // Audio unavailable — timer and visuals still run
        }
    }

    @MainActor
    private func runGuidedTrackTimer() async {
        while true {
            guard !Task.isCancelled else { return }
            guard let start = exerciseStartDate else { return }

            let currentPause = isPaused ? (pauseStartDate.map { Date().timeIntervalSince($0) } ?? 0) : 0
            let effectiveElapsed = Date().timeIntervalSince(start) - totalPausedDuration - currentPause
            if effectiveElapsed >= Double(selectedDuration * 60) {
                break
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        guard !Task.isCancelled else { return }
        completeGuidedTrackExercise()
    }

    @MainActor
    private func runVisualBreathCycle() async {
        while !Task.isCancelled {
            guard !Task.isCancelled else { return }
            breathPhase = .inhale
            await sleepWithPause(seconds: BreathPhase.inhale.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .hold
            await sleepWithPause(seconds: BreathPhase.hold.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .exhale
            await sleepWithPause(seconds: BreathPhase.exhale.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .rest
            await sleepWithPause(seconds: BreathPhase.rest.duration)
        }
    }

    @MainActor
    private func runCueBasedExercise() async {
        let cycles = selectedDuration * 4
        for _ in 0..<cycles {
            guard !Task.isCancelled else { return }
            breathPhase = .inhale
            playBreathingCue("breathing_inhale")
            await sleepWithPause(seconds: BreathPhase.inhale.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .hold
            playBreathingCue("breathing_hold")
            await sleepWithPause(seconds: BreathPhase.hold.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .exhale
            playBreathingCue("breathing_exhale")
            await sleepWithPause(seconds: BreathPhase.exhale.duration)

            guard !Task.isCancelled else { return }
            breathPhase = .rest
            playBreathingCue("breathing_rest")
            await sleepWithPause(seconds: BreathPhase.rest.duration)
        }

        guard !Task.isCancelled else { return }

        // Wait for any remaining active (non-paused) time so completion fires at 0:00
        if let start = exerciseStartDate {
            let effectiveElapsed = Date().timeIntervalSince(start) - totalPausedDuration
            let remaining = Double(selectedDuration * 60) - effectiveElapsed
            if remaining > 0 {
                await sleepWithPause(seconds: remaining)
            }
        }

        guard !Task.isCancelled else { return }
        completeExercise()
    }

    private func completeGuidedTrackExercise() {
        HapticManager.success()
        guard let player = audioPlayer, player.isPlaying else {
            dismiss()
            return
        }
        let remaining = max(0, player.duration - player.currentTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining + 0.5) {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.dismiss()
        }
    }

    private func completeExercise() {
        HapticManager.success()
        silentLoopPlayer?.stop()
        silentLoopPlayer = nil
        guard let url = Bundle.main.url(forResource: "breathing_complete", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
            return
        }
        try? AVAudioSession.sharedInstance().setActive(true)
        audioPlayer = player
        player.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    BreathingExerciseView()
}
