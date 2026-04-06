//
//  MeditationPlayerModel.swift
//  Mindful Moments
//
//  Timer and playback state for the meditation player
//

import Foundation
import Observation

@Observable
class MeditationPlayerModel {
    var timeRemaining: Int = 0
    var isPlaying: Bool = false
    var isCompleted: Bool = false
    var progress: Double = 1.0
    
    private var totalDuration: Int = 0
    private var timer: Timer?
    
    init() {}
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func setup(duration: Int) {
        totalDuration = duration * 60
        timeRemaining = totalDuration
        progress = 1.0
        isCompleted = false
    }
    
    func play() {
        guard timeRemaining > 0 else { return }
        isPlaying = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    self.progress = Double(self.timeRemaining) / Double(self.totalDuration)
                    
                    if self.timeRemaining == 0 {
                        self.isPlaying = false
                        self.isCompleted = true
                        self.timer?.invalidate()
                    }
                } else {
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    func pause() {
        isPlaying = false
        timer?.invalidate()
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
    }
    
    deinit {
        timer?.invalidate()
    }
}
