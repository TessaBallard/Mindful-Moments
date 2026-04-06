# Mindful Moments — app overview

## What it is

**Mindful Moments** is a SwiftUI iOS app for guided-style meditation practice: themed sessions (Calm, Sleep, Focus, Stress Relief, Energy, Gratitude), mood check-ins, progress tracking, journaling, favorites, achievements, reminders, and optional background sounds.

## Entry and navigation

- **`Mindful_MomentsApp.swift`** — Shows `WelcomeView` until `hasSeenWelcome` is set, then `ContentView`.
- **`ContentView.swift`** — Home: header (“Mindful Moments”), favorites carousel, meditation grid (liquid-glass style cards), links to **Progress**, **Journal**, **Settings**, optional background-sound tip, and **Quick Breathing**.
- **`MeditationThemeCard`** — Navigates to `MeditationDetailsView` per theme.
- **`MeditationDetailsView`** — Duration selection, “What to Expect”, **Start Session** → mood check-in (full screen) → `MeditationPlayerView`.
- **`MeditationPlayerView`** — Loading, timer/ring UI, sound controls, end flow → completion / journal prompts / mood check-out as applicable.
- **`CompletionCelebrationView`** — Post-session celebration with theme-matched gradient.

## Major screens (Views)

| View | Role |
|------|------|
| `WelcomeView` | First-launch onboarding |
| `ContentView` | Home hub |
| `MeditationDetailsView` | Per-theme session setup |
| `MeditationPlayerView` | In-session experience |
| `MoodCheckInView` | Before/after mood selection (4×2 grid, custom header mark) |
| `BreathingExerciseView` | Quick Breathing (durations 1–3 min, phases) |
| `ProgressView` | Stats, weekly chart, trends |
| `WeeklyProgressChart` | Week visualization |
| `MoodTrendsChart` | Mood trends |
| `JournalView` / `NewJournalEntryView` | Journal list and compose |
| `SettingsView` | Notifications, background sounds link |
| `BackgroundSoundSelectionView` | Sound picker + preview (custom gradient + header) |
| `CompletionCelebrationView` | Session complete |
| `AchievementCelebrationView` | Achievement unlock |

## Models and utilities

- **Themes & sessions:** `MeditationTheme`, `MeditationSession`, `SessionStore`
- **Audio:** `MeditationAudioManager`, `MeditationPlayerModel`, `BackgroundSound`, `BackgroundSoundManager`
- **Mood & journal:** `Mood`, `JournalEntry`, `JournalStore`
- **Engagement:** `FavoritesManager`, `AchievementsManager`, `Achievement`, `NotificationManager`, `ReminderSettings`
- **Utils:** `Fonts.swift`, `MeditationScreenGradients.swift`, `HapticManager.swift`

## File layout (source)

```
Mindful Moments/
├── ContentView.swift
├── Mindful_MomentsApp.swift
├── Models/          # Data and managers
├── Utils/           # Fonts, gradients, haptics
└── Views/           # All SwiftUI screens
```

## Dependencies

- SwiftUI, AVFoundation (audio), `UserDefaults` / `@AppStorage` for light persistence patterns.
