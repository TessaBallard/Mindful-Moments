//
//  SettingsView.swift
//  Mindful Moments
//
//  App settings and configuration
//

import SwiftUI

struct SettingsView: View {
    let notificationManager: NotificationManager
    let backgroundSoundManager: BackgroundSoundManager
    
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeData = Date().timeIntervalSince1970
    @AppStorage(VoicePreference.storageKey) private var guidedVoicePreference = VoicePreference.male.rawValue
    @State private var showingBackgroundSoundPicker = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var reminderTime: Date {
        Date(timeIntervalSince1970: reminderTimeData)
    }
    
    var body: some View {
        Form {
            Section("Audio") {
                Picker("Guide Voice", selection: $guidedVoicePreference) {
                    ForEach(VoicePreference.allCases) { voice in
                        Text(voice.displayName).tag(voice.rawValue)
                    }
                }
                .font(.brandSubheadline)
                .onChange(of: guidedVoicePreference) { _, _ in
                    HapticManager.selection()
                }

                Button(action: {
                    HapticManager.selection()
                    showingBackgroundSoundPicker = true
                }) {
                    HStack {
                        Image(systemName: backgroundSoundManager.selectedSound.iconName)
                            .foregroundStyle(.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Background Sound")
                                .font(.brandSubheadline)
                                .foregroundStyle(.primary)
                            
                            Text(backgroundSoundManager.selectedSound.displayName)
                                .font(.brandCaption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.appScaledSystem(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Section("Reminders") {
                Toggle("Daily Reminders", isOn: $dailyReminderEnabled)
                    .font(.brandSubheadline)
                    .onChange(of: dailyReminderEnabled) { oldValue, newValue in
                        if newValue {
                            Task {
                                await notificationManager.scheduleDailyReminder(at: reminderTime)
                            }
                        } else {
                            notificationManager.cancelDailyReminder()
                        }
                    }
                
                if dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { reminderTime },
                            set: { newValue in
                                reminderTimeData = newValue.timeIntervalSince1970
                                Task {
                                    await notificationManager.scheduleDailyReminder(at: newValue)
                                }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .font(.brandSubheadline)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                        .font(.brandSubheadline)
                    Spacer()
                    Text("1.0")
                        .font(.brandSubheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Made with")
                        .font(.brandSubheadline)
                    Spacer()
                    Text("💙")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingBackgroundSoundPicker) {
            NavigationStack {
                BackgroundSoundSelectionView(
                    selectedSound: Binding(
                        get: { backgroundSoundManager.selectedSound },
                        set: { backgroundSoundManager.selectedSound = $0 }
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(notificationManager: NotificationManager(), backgroundSoundManager: BackgroundSoundManager())
    }
}
