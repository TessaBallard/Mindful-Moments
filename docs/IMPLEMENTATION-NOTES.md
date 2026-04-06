# Mindful Moments — implementation notes

This document summarizes **documented work and product decisions** reflected in the codebase. It is not a full git history.

## Core product

- Six meditation themes from `MeditationTheme.sampleThemes` with descriptions, benefits, durations (5 / 10 / 15), and navigation into details → mood check-in → player → completion flows.
- **Session** persistence via `SessionStore`; **journal** via `JournalStore`; **favorites**, **achievements**, **notifications**, **background sounds** wired through dedicated managers.

## Home (`ContentView`)

- Liquid-glass style cards for theme grid and bottom **Progress** / **Journal** pills.
- Favorites horizontal section when any favorites exist.
- Optional “Did you know?” tip for background sounds (after enough sessions).
- **Quick Breathing** entry point (see `BreathingExerciseView`).

## Meditation details (`MeditationDetailsView`)

- Theme-specific reference styling (colors, duration chips, CTA, toolbar back button).
- Gradient background from `MeditationScreenGradients.themeColors`.
- Duration selection via `DurationButton` (reference vs fallback typography).
- “What to Expect” rows; **Start Session** opens mood check-in then player.

## Player (`MeditationPlayerView`)

- Theme-specific layouts (reference “ring” themes vs generic).
- Background gradient shared with details via `MeditationScreenGradients`.
- Timer fonts: mix of reference system sizes and `brandTimer` / `brandTitle3` where applicable.
- Loading overlay uses the same theme gradient as the main player.

## Mood check-in (`MoodCheckInView`)

- Before/after copy; **Cancel** and **Continue** / **Skip**.
- Custom header illustration (`MoodCheckInHeaderMark`) using a fixed accent blue.
- Compact mood grid (4 columns × 2 rows) and footer actions.

## Quick Breathing (`BreathingExerciseView`)

- Gradient from `MeditationScreenGradients.quickBreathingColors`.
- Duration chips aligned with meditation reference chip typography (`brandDurationDigit` / `brandDurationMinLabel`).
- Phased breathing UI with countdown and **Done**.

## Progress (`ProgressView`, charts)

- Weekly progress chart (`WeeklyProgressChart`), mood trends (`MoodTrendsChart`), stat tiles and copy using brand fonts.
- Streak and related stats presented per current design (banner vs tiles evolve over time—verify in source).

## Journal

- List and `NewJournalEntryView` for composing entries; navigation from home.

## Settings & background sounds

- `SettingsView` links to sound selection.
- `BackgroundSoundSelectionView`: custom marketing gradient, waveform + in-content title, **Done** in toolbar; grid of sounds with preview/stop, selection badge (`checkmark.circle.fill`), dark-mode preview pill contrast fixes.

## Completion & achievements

- `CompletionCelebrationView` uses theme gradient from `MeditationScreenGradients`.
- `AchievementCelebrationView` for unlock moments.

## Typography migration

- App moved from **Avenir** (`Font.custom`) to **SF Pro Rounded** via `Fonts.swift` and widespread `.system(..., design: .rounded)` on labels.
- Shared duration chip fonts: `brandDurationDigit`, `brandDurationMinLabel`.

## Gradients migration

- Theme and Quick Breathing backgrounds centralized in **`MeditationScreenGradients`** for consistency across detail, player, loading, completion.
- **Gratitude dark** gradient set to `#4d3e00` → `#ffcc00` (with player chrome top color aligned).

## Welcome

- First launch gated by `hasSeenWelcome`; welcome screen uses rounded system title styling.

---

*To refresh this doc after major changes, update the relevant section and cross-check `Fonts.swift`, `MeditationScreenGradients.swift`, and the affected `Views/` files.*
