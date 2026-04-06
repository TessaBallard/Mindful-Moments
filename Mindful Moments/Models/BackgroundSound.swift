//
//  BackgroundSound.swift
//  Mindful Moments
//
//  Model for background ambient sounds
//

import Foundation

enum BackgroundSound: String, CaseIterable, Codable, Identifiable {
    case river = "River"
    case ocean = "Ocean Waves"
    case rain = "Rain"
    case focus = "Focus"
    case sleep = "Sleep"
    case stressRelief = "Stress Relief"
    case energy = "Energy"
    case gratitude = "Gratitude"
    case none = "None"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .river: return "Gentle flowing water"
        case .ocean: return "Calm waves and tide"
        case .rain: return "Soft rainfall sounds"
        case .focus: return "Focused ambient tones"
        case .sleep: return "Relaxing sleep sounds"
        case .stressRelief: return "Calming stress relief"
        case .energy: return "Energizing ambient sounds"
        case .gratitude: return "Uplifting gratitude tones"
        case .none: return "Silent meditation"
        }
    }
    
    var iconName: String {
        switch self {
        case .river: return "water.waves"
        case .ocean: return "waveform.path"
        case .rain: return "cloud.rain.fill"
        case .focus: return "target"
        case .sleep: return "moon.stars.fill"
        case .stressRelief: return "heart.fill"
        case .energy: return "bolt.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .none: return "speaker.slash.fill"
        }
    }
    
    func fileName(for duration: Int) -> String? {
        guard self != .none else { return nil }
        
        switch self {
        case .river:
            return "river_background_\(duration)min.mp3"
        case .ocean:
            return "calm_ocean_waves_\(duration)_minutes.mp3"
        case .rain:
            if duration == 5 {
                return "calm_rain 5 minutes.mp3"
            } else {
                return "calm_rain_\(duration)_ minutes.mp3"
            }
        case .focus:
            return "focus_ambient_\(duration)_minutes.mp3"
        case .sleep:
            if duration == 10 {
                return "sleep_ambient_\(duration) minutes.mp3"
            } else {
                return "sleep_ambient_\(duration)_minutes.mp3"
            }
        case .stressRelief:
            return "stress_relief_ambient_\(duration)_minutes.mp3"
        case .energy:
            return "energy_ambient_\(duration)_minutes.mp3"
        case .gratitude:
            return "gratitude_ambient_\(duration)_minutes.mp3"
        case .none:
            return nil
        }
    }
}
