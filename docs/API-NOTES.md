# Mindful Moments — API & integration notes

Technical reference for **audio**, **session persistence**, **player timing**, and related **UserDefaults** keys. Use this when adding assets, debugging playback, or integrating new flows.

---

## Audio — `MeditationAudioManager`

**File:** `Models/MeditationAudioManager.swift`  
**Framework:** `AVFoundation` (`AVAudioPlayer`, `AVAudioSession`)

### Session

- Category: **`.playback`**, mode **`.default`**, options **`.mixWithOthers`**.
- Configured in `init` via `configureAudioSession()`.

### Voice (guided) tracks

`startMeditation(themeName:duration:backgroundSound:)` resolves the voice asset as:

1. **Theme slug:** lowercased `themeName`, except **Stress Relief** → `"stress"`.
2. **Filename:** `"{slug}_meditation_{duration}min.mp3"`  
   Example: `calm_meditation_5min.mp3`, `stress_meditation_10min.mp3`.

If the file is missing, `audioError` is set and playback does not start.

### Background (ambient) tracks

- If `backgroundSound` is **`.none`** or `fileName(for: duration)` returns `nil`, only the voice player runs.
- Otherwise loads the URL returned by `BackgroundSound.fileName(for:)` (see below). Background starts first, then voice.
- **Voice** volume: `1.0`. **Background** volume: `backgroundVolume` (default `0.015`) unless `isBackgroundMuted`.

### Public surface (summary)

| Method / property | Purpose |
|-------------------|--------|
| `startMeditation(themeName:duration:backgroundSound:)` | Load and play voice ± background |
| `pause()` / `resume()` | Pause/resume both players |
| `stopMeditation()` | Stop and clear playing state |
| `setBackgroundVolume(_:)` | Persist-level control; updates live player if not muted |
| `toggleBackgroundMute()` | Mute/unmute background track |
| `isPlaying`, `isSpeaking`, `audioError`, `isBackgroundMuted` | UI / error state |

`audioPlayerDidFinishPlaying` sets `isSpeaking = false` when the **voice** player finishes (background may still be playing until session ends in UI).

---

## Background sounds — `BackgroundSound` & `BackgroundSoundManager`

**Files:** `Models/BackgroundSound.swift`, `Models/BackgroundSoundManager.swift`

### Persistence

- Key: **`selectedBackgroundSound`** (JSON-encoded `BackgroundSound`).
- Default selection: **`.river`** if nothing saved.

### Bundle filenames (`fileName(for: Int)`)

Naming is **duration-specific** and includes a few special cases (spaces / wording) that must match actual files in the app bundle:

| Case | Pattern / notes |
|------|------------------|
| River | `river_background_{duration}min.mp3` |
| Ocean | `calm_ocean_waves_{duration}_minutes.mp3` |
| Rain | `5` → `calm_rain 5 minutes.mp3`; others → `calm_rain_{duration}_ minutes.mp3` (note space before `minutes`) |
| Focus | `focus_ambient_{duration}_minutes.mp3` |
| Sleep | `10` → `sleep_ambient_10 minutes.mp3`; others → `sleep_ambient_{duration}_minutes.mp3` |
| Stress Relief | `stress_relief_ambient_{duration}_minutes.mp3` |
| Energy | `energy_ambient_{duration}_minutes.mp3` |
| Gratitude | `gratitude_ambient_{duration}_minutes.mp3` |
| None | `nil` |

Adding a new sound requires updating this enum **and** adding matching resources.

---

## Player timer — `MeditationPlayerModel`

**File:** `Models/MeditationPlayerModel.swift`

- **Not** tied to `AVAudioPlayer` duration; drives UI countdown independently.
- `setup(duration:)` — `duration` is **minutes**; internal store is seconds (`duration * 60`).
- `play()` — 1-second repeating `Timer`; decrements `timeRemaining`, updates `progress`, sets `isCompleted` and stops at `0`.
- `pause()` / `stop()` — invalidate timer; `stop` does not reset time (caller typically re-`setup`s if needed).
- `timeString` — `"M:SS"` for display.

The UI should align session end (completion, `stopMeditation`, etc.) with this model so the ring and audio don’t disagree.

---

## Sessions — `SessionStore` & `MeditationSession`

**Files:** `Models/SessionStore.swift`, `Models/MeditationSession.swift`

### `MeditationSession` (Codable)

Fields: `id`, `date`, `duration` (minutes), `themeName`, `themeColor`, `themeIcon`, `moodBefore`, `moodAfter`.  
Helpers: `hadMoodImprovement`, `moodChangeScore` (uses `Mood.score`).

### `SessionStore` persistence

| Key | Content |
|-----|--------|
| `savedMeditationSessions` | JSON array of `MeditationSession` |
| `lastKnownStreak` | Int (UserDefaults integer) |
| `streakBrokenDate` | `Date?` for streak recovery messaging |

### Useful API

- `addSession(_:)` — prepends and saves.
- `totalMinutes`, `totalSessions`, `recentSessions` (last 7 days).
- `currentStreak` — consecutive calendar days with at least one session; updates `lastKnownStreak` / `streakBrokenDate` when broken.
- `moodImprovementRate`, `mostCommonMoodBefore` / `After`, `streakRecoveryMessage`, `mostRecentSession`.

---

## Journal — `JournalStore`

**File:** `Models/JournalStore.swift`

- Key: **`savedJournalEntries`** — JSON array of `JournalEntry`.
- `addEntry` / `deleteEntry` — mutate `entries` (newest first) and save.

---

## Favorites — `FavoritesManager`

**File:** `Models/FavoritesManager.swift`

- Key: **`favoriteThemes`** — array of theme name strings (`Set` restored on load).
- `toggleFavorite`, `isFavorite`, `getFavorites(from:)`.

---

## Preview audio (settings UI)

**File:** `Views/BackgroundSoundSelectionView.swift`

Uses local `AVAudioPlayer` instances (not `MeditationAudioManager`) for grid previews. Voice preview may use a fixed asset such as `calm_meditation_5min.mp3` when “Preview with Voice” is on—confirm in that file if you change bundled meditations.

---

## Related docs

- [APP-OVERVIEW.md](./APP-OVERVIEW.md) — screens and navigation  
- [DESIGN-SYSTEM.md](./DESIGN-SYSTEM.md) — typography and gradients  
