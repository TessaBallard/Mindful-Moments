//
//  SettingsView.swift
//  Mindful Moments
//
//  App settings and configuration
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    let notificationManager: NotificationManager
    let backgroundSoundManager: BackgroundSoundManager
    let subscriptionManager: SubscriptionManager

    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeData = Date().timeIntervalSince1970
    @AppStorage(VoicePreference.storageKey) private var guidedVoicePreference = VoicePreference.male.rawValue
    @State private var showingBackgroundSoundPicker = false
    @State private var showingPaywall = false
    @Environment(\.colorScheme) private var colorScheme

    private var reminderTime: Date {
        Date(timeIntervalSince1970: reminderTimeData)
    }

    var body: some View {
        Form {
            Section {
                if subscriptionManager.isPlusActive {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Mindful Moments Plus")
                            .font(.brandSubheadline)
                        Spacer()
                        Text("Active")
                            .font(.brandCaption)
                            .foregroundStyle(.secondary)
                    }

                    Button("Manage Subscription") {
                        Task { await showManageSubscriptions() }
                    }
                    .font(.brandSubheadline)
                } else {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mindful Moments Plus")
                                    .font(.brandSubheadline)
                                    .foregroundStyle(.primary)
                                Text("Unlock Self-Compassion & Body Scan")
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
            } header: {
                Text("Subscription")
            } footer: {
                Text("All existing meditations, streak tracking, and features remain free.")
                    .font(.brandCaption)
            }

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

            Section {
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
            } header: {
                Text("Reminders")
            } footer: {
                Text("A gentle daily nudge to help you build a mindful habit. Messages vary through the week.")
                    .font(.brandCaption)
            }

            Section("About") {
                HStack {
                    Text("Version")
                        .font(.brandSubheadline)
                    Spacer()
                    Text("1.3")
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
                    ),
                    isPlusActive: subscriptionManager.isPlusActive
                )
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PlusPaywallView(subscriptionManager: subscriptionManager)
        }
        .onChange(of: showingPaywall) { _, isShowing in
            if !isShowing {
                Task { await subscriptionManager.refreshEntitlements() }
            }
        }
    }

    @MainActor
    private func showManageSubscriptions() async {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        try? await AppStore.showManageSubscriptions(in: windowScene)
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            notificationManager: NotificationManager(),
            backgroundSoundManager: BackgroundSoundManager(),
            subscriptionManager: SubscriptionManager()
        )
    }
}
