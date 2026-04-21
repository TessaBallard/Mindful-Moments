//
//  MeditationAudioManager.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 06/12/2025.
//

import Foundation
import AVFoundation

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
        configureAudioSession()
    }
    
    /// Configure audio session for meditation
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    /// Start meditation with audio file based on theme and duration.
    /// Pass `guidedVoice: false` to play background ambient sound only.
    func startMeditation(themeName: String, duration: Int, backgroundSound: BackgroundSound = .river, guidedVoice: Bool = true) {
        if !guidedVoice {
            startBackgroundOnly(duration: duration, backgroundSound: backgroundSound)
            return
        }

        var themeFileName: String
        if themeName == "Stress Relief" {
            themeFileName = "stress"
        } else {
            themeFileName = themeName.lowercased()
        }
        
        let voiceFileName = "\(themeFileName)_meditation_\(duration)min"
        
        guard let voiceURL = Bundle.main.url(forResource: voiceFileName, withExtension: "mp3") else {
            print("❌ Voice file not found: \(voiceFileName).mp3")
            audioError = "Meditation audio not found. Please try another meditation."
            return
        }
        
        audioError = nil
        
        if let backgroundFileName = backgroundSound.fileName(for: duration),
           let backgroundURL = Bundle.main.url(forResource: backgroundFileName, withExtension: nil) {
            
            print("✅ Loading audio files:")
            print("   Voice: \(voiceFileName).mp3")
            print("   Background: \(backgroundFileName)")
            
            do {
                voicePlayer = try AVAudioPlayer(contentsOf: voiceURL)
                voicePlayer?.delegate = self
                voicePlayer?.volume = 1.0
                
                let voiceReady = voicePlayer?.prepareToPlay() ?? false
                let voiceDuration = voicePlayer?.duration ?? 0
                print("   Voice player ready: \(voiceReady), duration: \(voiceDuration)s")
                
                backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
                backgroundPlayer?.delegate = self
                backgroundPlayer?.volume = isBackgroundMuted ? 0.0 : backgroundVolume
                backgroundPlayer?.numberOfLoops = 0
                
                let backgroundReady = backgroundPlayer?.prepareToPlay() ?? false
                let backgroundDuration = backgroundPlayer?.duration ?? 0
                print("   Background player ready: \(backgroundReady), duration: \(backgroundDuration)s")
                
                backgroundPlayer?.play()
                let voicePlaying = voicePlayer?.play() ?? false
                
                isPlaying = true
                isSpeaking = true
            
                print("▶️ Playing meditation:")
                print("   Voice playing: \(voicePlaying) at volume \(voicePlayer?.volume ?? 0)")
                print("   Background at volume \(backgroundPlayer?.volume ?? 0)")
                
                if voiceDuration == 0 {
                    print("⚠️ WARNING: Voice file has 0 duration!")
                }
                
                if !voicePlaying {
                    print("⚠️ Warning: Voice player failed to start!")
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
                voicePlayer?.prepareToPlay()
                voicePlayer?.play()
                
                isPlaying = true
                isSpeaking = true
                
                print("▶️ Playing voice-only meditation")
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

        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: backgroundURL)
            backgroundPlayer?.delegate = self
            // Use a more audible volume for background-only mode
            let vol: Float = isBackgroundMuted ? 0.0 : max(backgroundVolume, 0.5)
            backgroundPlayer?.volume = vol
            backgroundVolume = isBackgroundMuted ? backgroundVolume : max(backgroundVolume, 0.5)
            backgroundPlayer?.numberOfLoops = 0
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()

            isPlaying = true
            isSpeaking = false

            print("▶️ Playing background-only meditation at volume \(vol)")
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
