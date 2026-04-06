//
//  MoodTrendsChart.swift
//  Mindful Moments
//
//  Mood trends visualization showing before/after meditation
//

import SwiftUI

struct MoodTrendsChart: View {
    let sessions: [MeditationSession]
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var moodSessions: [MeditationSession] {
        sessions
            .filter { $0.moodBefore != nil && $0.moodAfter != nil }
            .prefix(10)
            .reversed()
    }
    
    private var averageImprovement: Double {
        guard !moodSessions.isEmpty else { return 0 }
        let total = moodSessions.reduce(0.0) { sum, session in
            return sum + Double(session.moodChangeScore)
        }
        return total / Double(moodSessions.count)
    }
    
    private var mostCommonBefore: Mood? {
        let moods = moodSessions.compactMap { $0.moodBefore }
        guard !moods.isEmpty else { return nil }
        let counts = Dictionary(grouping: moods) { $0 }
        return counts.max { $0.value.count < $1.value.count }?.key
    }
    
    private var mostCommonAfter: Mood? {
        let moods = moodSessions.compactMap { $0.moodAfter }
        guard !moods.isEmpty else { return nil }
        let counts = Dictionary(grouping: moods) { $0 }
        return counts.max { $0.value.count < $1.value.count }?.key
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Trends")
                        .font(.brandHeadline)
                        .foregroundStyle(.primary)
                    
                    Text("\(moodSessions.count) sessions tracked")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if moodSessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("Complete meditations with mood check-ins to see trends")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        if let before = mostCommonBefore {
                            MoodTrendStat(label: "Most Common Before", mood: before)
                        }
                        
                        if let after = mostCommonAfter {
                            MoodTrendStat(label: "Most Common After", mood: after)
                        }
                    }
                    
                    if averageImprovement > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.heart.fill")
                                .foregroundStyle(.green)
                            
                            Text("Average mood improves by \(String(format: "%.1f", averageImprovement)) points")
                                .font(.brandCaption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
            }
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
        .opacity(showContent ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
                showContent = true
            }
        }
    }
}

struct MoodTrendStat: View {
    let label: String
    let mood: Mood
    
    var body: some View {
        VStack(spacing: 8) {
            Text(mood.emoji)
                .font(.system(size: 32, design: .rounded))
            
            Text(mood.displayName)
                .font(.brandCaption)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        MoodTrendsChart(sessions: [])
            .padding()
    }
}
