//
//  WeeklyProgressChart.swift
//  Mindful Moments
//
//  Weekly progress bar chart visualization
//

import SwiftUI

struct WeeklyProgressChart: View {
    let sessions: [MeditationSession]
    @State private var showBars = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var weeklyData: [(day: String, count: Int, date: Date)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var data: [(day: String, count: Int, date: Date)] = []
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let count = sessions.filter { session in
                session.date >= dayStart && session.date < dayEnd
            }.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let dayName = formatter.string(from: date)
            
            data.append((day: dayName, count: count, date: date))
        }
        
        return data
    }
    
    private var maxCount: Int {
        weeklyData.map { $0.count }.max() ?? 1
    }
    
    private var totalThisWeek: Int {
        weeklyData.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.brandHeadline)
                        .foregroundStyle(.primary)
                    
                    Text("\(totalThisWeek) sessions")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("Last 7 days")
                        .font(.brandCaption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 8) {
                        Text(data.count > 0 ? "\(data.count)" : "")
                            .font(.brandCaption)
                            .foregroundStyle(.secondary)
                            .frame(height: 16)
                            .opacity(showBars ? 1.0 : 0.0)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05))
                                .frame(height: 100)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            barColor(for: data.date).opacity(0.9),
                                            barColor(for: data.date).opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: showBars ? CGFloat(data.count) / CGFloat(maxCount) * 100 : 0)
                        }
                        .frame(height: 100)
                        
                        Text(data.day)
                            .font(.brandCaption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showBars = true
                }
            }
        }
    }
    
    private func barColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if calendar.isDate(date, inSameDayAs: today) {
            return .cyan
        } else {
            return .indigo
        }
    }
}

#Preview {
    ScrollView {
        WeeklyProgressChart(sessions: [])
            .padding()
    }
}
