//
//  BackgroundSoundSelectionView.swift
//  Mindful Moments
//
//  Background sound selection with preview
//

import SwiftUI
import AVFoundation

struct BackgroundSoundSelectionView: View {
    @Binding var selectedSound: BackgroundSound
    var isPlusActive: Bool = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var previewPlayer: AVAudioPlayer?
    @State private var voicePreviewPlayer: AVAudioPlayer?
    @State private var previewingSound: BackgroundSound?
    @State private var previewWithVoice = false
    
    /// Settings-style background: light #5ba4e6 → #38a3a5, dark #6f86d6 → #48c6ef
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 111 / 255, green: 134 / 255, blue: 214 / 255),
                Color(red: 72 / 255, green: 198 / 255, blue: 239 / 255)
            ]
        }
        return [
            Color(red: 91 / 255, green: 164 / 255, blue: 230 / 255),
            Color(red: 56 / 255, green: 163 / 255, blue: 165 / 255)
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                soundOptionsView
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    stopPreview()
                    dismiss()
                }
            }
        }
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onDisappear {
            stopPreview()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.38) : Color.white.opacity(0.55))
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.14), radius: 10, x: 0, y: 4)
                    Image(systemName: "waveform")
                        .font(.appScaledSystem(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color(red: 0.06, green: 0.22, blue: 0.48))
                        .symbolRenderingMode(.monochrome)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.22 : 0.65), lineWidth: 1)
                        .frame(width: 80, height: 80)
                }
                
                Text("Background Sounds")
                    .font(.brandLargeTitle)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)
            
            Text("Choose your ambient sound to accompany your meditation practice")
                .font(.brandSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                Image(systemName: previewWithVoice ? "mic.fill" : "mic.slash.fill")
                    .font(.appScaledSystem(size: 16, design: .rounded))
                    .foregroundStyle(previewWithVoice ? .cyan : .secondary)
                
                Toggle("Preview with Voice", isOn: $previewWithVoice)
                    .font(.brandCaption)
                    .onChange(of: previewWithVoice) { oldValue, newValue in
                        if previewingSound != nil {
                            stopPreview()
                            if let sound = previewingSound {
                                playPreview(sound)
                            }
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private var soundOptionsView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(BackgroundSound.sounds(isPlusActive: isPlusActive)) { sound in
                BackgroundSoundCard(
                    sound: sound,
                    isSelected: selectedSound == sound,
                    isPreviewing: previewingSound == sound,
                    onSelect: {
                        HapticManager.light()
                        selectedSound = sound
                        stopPreview()
                    },
                    onPreview: {
                        HapticManager.selection()
                        if previewingSound == sound {
                            stopPreview()
                        } else {
                            playPreview(sound)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func playPreview(_ sound: BackgroundSound) {
        stopPreview()
        
        guard sound != .none else {
            previewingSound = nil
            return
        }
        
        previewingSound = sound
        
        if let fileName = sound.fileName(for: 5),
           let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                previewPlayer = try AVAudioPlayer(contentsOf: url)
                previewPlayer?.volume = 0.3
                previewPlayer?.numberOfLoops = -1
                previewPlayer?.play()
                
                if previewWithVoice {
                    if let voiceURL = Bundle.main.url(forResource: "calm_meditation_5min", withExtension: "mp3") {
                        voicePreviewPlayer = try AVAudioPlayer(contentsOf: voiceURL)
                        voicePreviewPlayer?.volume = 1.0
                        voicePreviewPlayer?.numberOfLoops = -1
                        voicePreviewPlayer?.play()
                    }
                }
            } catch {
                print("Error playing preview: \(error)")
            }
        }
    }
    
    private func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        voicePreviewPlayer?.stop()
        voicePreviewPlayer = nil
        previewingSound = nil
    }
}

struct BackgroundSoundCard: View {
    let sound: BackgroundSound
    let isSelected: Bool
    let isPreviewing: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var previewForegroundColor: Color {
        if isPreviewing {
            return isDark ? Color(red: 1, green: 0.52, blue: 0.55) : .red
        }
        return isDark ? Color(red: 0.55, green: 0.84, blue: 1) : .blue
    }
    
    private var previewPillFill: Color {
        if isPreviewing {
            return isDark ? Color.red.opacity(0.28) : Color.red.opacity(0.1)
        }
        return isDark ? Color(red: 0.25, green: 0.55, blue: 0.95).opacity(0.38) : Color.blue.opacity(0.1)
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08),
                                    Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: sound.iconName)
                        .font(.appScaledSystem(size: 28, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .frame(width: 72, height: 72)
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.appScaledSystem(size: 24, weight: .semibold, design: .rounded))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color(red: 0, green: 0.478, blue: 1))
                            .offset(x: 4, y: -4)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(sound.displayName)
                        .font(.brandHeadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    Text(sound.description)
                        .font(.appScaledSystem(size: 11, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if sound != .none {
                    Button(action: onPreview) {
                        HStack(spacing: 4) {
                            Image(systemName: isPreviewing ? "stop.fill" : "play.fill")
                                .font(.appScaledSystem(size: 10, weight: .semibold, design: .rounded))
                            Text(isPreviewing ? "Stop" : "Preview")
                                .font(.brandCaption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(previewForegroundColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(previewPillFill)
                                .overlay {
                                    if isDark {
                                        Capsule()
                                            .strokeBorder(
                                                Color.white.opacity(isPreviewing ? 0.32 : 0.42),
                                                lineWidth: 1
                                            )
                                    }
                                }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text(" ")
                        .font(.brandCaption)
                        .padding(.vertical, 6)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    LinearGradient(
                        colors: isSelected
                            ? [Color.blue.opacity(0.15), Color.cyan.opacity(0.1)]
                            : [Color.primary.opacity(colorScheme == .dark ? 0.05 : 0.02), Color.primary.opacity(colorScheme == .dark ? 0.03 : 0.01)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: isSelected
                                ? [.blue.opacity(0.5), .cyan.opacity(0.3)]
                                : [Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1), Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
            .shadow(color: isSelected ? Color.blue.opacity(0.2) : Color.clear, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(SpringScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sound.displayName) background sound")
        .accessibilityHint("\(sound.description). \(isSelected ? "Currently selected." : "Double tap to select.") Tap preview button to hear sample.")
    }
}

#Preview {
    NavigationStack {
        BackgroundSoundSelectionView(selectedSound: .constant(.river))
    }
}
