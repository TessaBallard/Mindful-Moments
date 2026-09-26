//
//  MeditationAudioManager.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation
import AVFoundation

enum VoicePreference: String, CaseIterable, Identifiable {
    case male
    case female

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return "Male (Dominic)"
        case .female: return "Female (Mira)"
        }
    }

    var fileSuffix: String {
        switch self {
        case .male: return ""
        case .female: return "_mira"
        }
    }

    static let storageKey = "guidedVoicePreference"

    static var current: VoicePreference {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? VoicePreference.male.rawValue
        return VoicePreference(rawValue: raw) ?? .male
    }

    static func save(_ preference: VoicePreference) {
        UserDefaults.standard.set(preference.rawValue, forKey: storageKey)
    }

    static func meditationVoiceFileName(themeName: String, duration: Int, voice: VoicePreference = current) -> String {
        let themeFileName: String
        let isPlusTheme: Bool
        switch themeName {
        case "Stress Relief":
            themeFileName = "stress"
            isPlusTheme = false
        case "Self-Compassion":
            themeFileName = "selfcompassion"
            isPlusTheme = true
        case "Body Scan":
            themeFileName = "bodyscan"
            isPlusTheme = true
        default:
            themeFileName = themeName.lowercased()
            isPlusTheme = false
        }

        let voiceSuffix: String
        if isPlusTheme {
            voiceSuffix = voice == .male ? "_dominic" : "_mira"
        } else {
            voiceSuffix = voice.fileSuffix
        }

        return "\(themeFileName)_meditation_\(duration)min\(voiceSuffix)"
    }

    static func breathingVoiceFileName(duration: Int) -> String {
        "breathing_meditation_\(duration)min\(current.fileSuffix)"
    }
}

/// Manages audio playback for meditation guidance with voice and background audio
@Observable
class MeditationAudioManager: NSObject, AVAudioPlayerDelegate {
    var isSpeaking: Bool = false
    var isPlaying: Bool = false
    var backgroundVolume: Float = 0.015  // Default 1.5% volume
    var audioError: String? = nil  // Track audio loading errors
    var isBackgroundMuted: Bool = false
    
    // Dual audio players for voice and background mixing
    private var voicePlayer: AVAudioPlayer?
    private var backgroundPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        activateAudioSessionForPlayback()
    }

    /// Ensures the shared audio session is ready before AVAudioPlayer starts.
    @discardableResult
    private func activateAudioSessionForPlayback() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            return true
        } catch {
            print("⚠️ Audio session activate failed (first attempt): \(error)")
        }

        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            print("✅ Audio session configured successfully (after reset)")
            return true
        } catch {
            print("❌ Failed to configure audio session: \(error)")
            return false
        }
    }

    private func startPlayer(_ player: AVAudioPlayer?, label: String) -> Bool {
        guard let player else { return false }
        _ = activateAudioSessionForPlayback()
        player.prepareToPlay()
        if player.play() {
            return true
        }
        print("⚠️ \(label) failed to start — retrying after audio session refresh")
        _ = activateAudioSessionForPlayback()
        player.prepareToPlay()
        let started = player.play()
        if !started {
            print("⚠️ \(label) still failed to start (duration: \(player.duration)s)")
        }
        return started
    }
    
    /// Start meditation with audio file based on theme and duration.
    /// Pass `guidedVoice: false` to play background ambient sound only.
    func startMeditation(themeName: String, duration: Int, backgroundSound: BackgroundSound = .river, guidedVoice: Bool = true) {
        if !guidedVoice {
            startBackgroundOnly(duration: duration, backgroundSound: backgroundSound)
            return
        }

        let voiceFileName = VoicePreference.meditationVoiceFileName(themeName: themeName, duration: duration)
        
        guard let voiceURL = Bundle.main.url(forResource: voiceFileName, withExtension: "mp3") else {
            print("❌ Voice file not found: \(voiceFileName).mp3")
            audioError = "Meditation audio not found. Please try another meditation."
            return
        }
        
        audioError = nil
        _ = activateAudioSessionForPlayback()

        if let backgroundFileName = backgroundSound.fileName(for: duration),
           let backgroundURL = Bundle.main.url(forResource: backgroundFileName, withExtension: nil) {

            print("✅ Loading audio files:")
            print("   Voice: \(voiceFileName).mp3")
            print("   Background: \(backgroundFileName)")

            do {
                voicePlayer = try AVAudioPlayer(contentsOf: voiceURL)
                voicePlayer?.delegate = self
                voicePlayer?.volume = 1.0

                backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
                backgroundPlayer?.delegate = self
                backgroundPlayer?.volume = isBackgroundMuted ? 0.0 : backgroundVolume
                backgroundPlayer?.numberOfLoops = 0

                let voiceDuration = voicePlayer?.duration ?? 0
                let backgroundDuration = backgroundPlayer?.duration ?? 0
                print("   Voice duration: \(voiceDuration)s, background duration: \(backgroundDuration)s")

                if voiceDuration == 0 {
                    print("⚠️ WARNING: Voice file has 0 duration — check MP3 export in bundle")
                    audioError = "Meditation audio could not be loaded. Please try again."
                    return
                }

                let voicePlaying = startPlayer(voicePlayer, label: "Voice")
                let backgroundPlaying = startPlayer(backgroundPlayer, label: "Background")

                isPlaying = voicePlaying || backgroundPlaying
                isSpeaking = voicePlaying

                print("▶️ Playing meditation:")
                print("   Voice playing: \(voicePlaying) at volume \(voicePlayer?.volume ?? 0)")
                print("   Background playing: \(backgroundPlaying) at volume \(backgroundPlayer?.volume ?? 0)")

                if !voicePlaying {
                    audioError = "Guided voice could not start. Please try again."
                }
            } catch {
                print("❌ Failed to play audio: \(error)")
                audioError = "Failed to load audio. Please try again."
            }
        } else {
            do {
                voicePlayer = try AVAudioPlayer(contentsOf: voiceURL)
                voicePlayer?.delegate = self
                voicePlayer?.volume = 1.0

                let voicePlaying = startPlayer(voicePlayer, label: "Voice")
                isPlaying = voicePlaying
                isSpeaking = voicePlaying

                if voicePlaying {
                    print("▶️ Playing voice-only meditation")
                } else {
                    audioError = "Guided voice could not start. Please try again."
                }
            } catch {
                print("❌ Failed to play audio: \(error)")
                audioError = "Failed to load audio. Please try again."
            }
        }
    }

    /// Play background ambient sound only (no guided voice).
    private func startBackgroundOnly(duration: Int, backgroundSound: BackgroundSound) {
        // "None" selected = silent session — just run the timer with no audio, no error
        if backgroundSound == .none {
            isPlaying = true
            isSpeaking = false
            print("▶️ Silent session (no voice, no background sound)")
            return
        }

        guard let backgroundFileName = backgroundSound.fileName(for: duration),
              let backgroundURL = Bundle.main.url(forResource: backgroundFileName, withExtension: nil) else {
            print("❌ Background file not found for background-only mode")
            audioError = "Background audio not found. Please try again."
            return
        }

        audioError = nil
        _ = activateAudioSessionForPlayback()

        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
            backgroundPlayer?.delegate = self
            // Use a more audible volume for background-only mode
            let vol: Float = isBackgroundMuted ? 0.0 : max(backgroundVolume, 0.5)
            backgroundPlayer?.volume = vol
            backgroundVolume = isBackgroundMuted ? backgroundVolume : max(backgroundVolume, 0.5)
            backgroundPlayer?.numberOfLoops = 0

            let started = startPlayer(backgroundPlayer, label: "Background")
            isPlaying = started
            isSpeaking = false

            print("▶️ Playing background-only meditation at volume \(vol), started: \(started)")
        } catch {
            print("❌ Failed to play background audio: \(error)")
            audioError = "Failed to load audio. Please try again."
        }
    }
    
    func pause() {
        voicePlayer?.pause()
        backgroundPlayer?.pause()
        isPlaying = false
    }
    
    func resume() {
        _ = activateAudioSessionForPlayback()
        voicePlayer?.play()
        backgroundPlayer?.play()
        isPlaying = true
    }
    
    func stopMeditation() {
        voicePlayer?.stop()
        backgroundPlayer?.stop()
        isPlaying = false
        isSpeaking = false
    }
    
    func setBackgroundVolume(_ volume: Float) {
        backgroundVolume = volume
        if !isBackgroundMuted {
            backgroundPlayer?.volume = volume
        }
    }
    
    func toggleBackgroundMute() {
        isBackgroundMuted.toggle()
        backgroundPlayer?.volume = isBackgroundMuted ? 0.0 : backgroundVolume
    }
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == voicePlayer {
            isSpeaking = false
            print("✅ Voice playback finished")
        }
    }
}
