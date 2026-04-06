# Mindful Moments — design system (code)

Values below match the current Swift implementation. Always confirm in `Fonts.swift` and `MeditationScreenGradients.swift` if something looks off.

## Typography

**Family:** SF Pro **Rounded** app-wide (replaced prior Avenir-based `Font.custom` usage).

Defined in **`Mindful Moments/Utils/Fonts.swift`** as `Font` static members:

| Token | Approximate spec |
|-------|------------------|
| `brandLargeTitle` | 34 pt, bold, rounded |
| `brandTitle` | 28 pt, bold, rounded |
| `brandTitle2` | 22 pt, medium, rounded |
| `brandTitle3` | 20 pt, medium, rounded |
| `brandNavigationTitle` | 34 pt, bold, rounded |
| `brandHeadline` | 17 pt, medium, rounded |
| `brandSubheadline` | 15 pt, regular, rounded |
| `brandBody` | 16 pt, regular, rounded |
| `brandCaption` | 12 pt, regular, rounded |
| `brandDurationDigit` | 35 pt, bold, rounded (meditation duration chips) |
| `brandDurationMinLabel` | 11 pt, semibold, rounded + tracking on chips |
| `brandNumber` | 48 pt, bold, rounded (non–reference-style duration fallback) |
| `brandNumberMedium` | 32 pt, medium, rounded |
| `brandTimer` | 56 pt, bold, rounded |

Many views also use explicit `.font(.system(size:weight:design: .rounded))` for one-off sizes (home header, charts, icons, etc.).

## Meditation screen gradients

Centralized in **`Mindful Moments/Utils/MeditationScreenGradients.swift`**.

- **`themeColors(themeName:isDark:)`** — Used by meditation **detail**, **player**, **loading**, and **completion** backgrounds (vertical gradient top → bottom unless a view overrides axis).
- **`quickBreathingColors(isDark:)`** — Quick Breathing + Background Sounds screen (that screen uses its own marketing gradient in `BackgroundSoundSelectionView`; Quick Breathing uses the quick-breathing pair).

### Theme pairs (hex, light / dark)

| Theme | Light | Dark |
|-------|--------|------|
| Quick Breathing | `#00c0e8` → `#a3e8f5` | `#004b5c` → `#00c0e8` |
| Calm | `#00c8b3` → `#99e6de` | `#003e39` → `#00c8b3` |
| Sleep | `#6155f5` → `#a8a2f9` | `#1f1a4e` → `#6155f5` |
| Focus | `#0088ff` → `#99cfff` | `#002c53` → `#0088ff` |
| Stress Relief | `#ff2d55` → `#ffb8c5` | `#550012` → `#ff2d55` |
| Energy | `#ff8d28` → `#ffd4ab` | `#4e2200` → `#ff8d28` |
| Gratitude | `#ffcc00` → `#fff3c2` | `#4d3e00` → `#ffcc00` |

### Background Sounds (settings)

`BackgroundSoundSelectionView` uses a **separate** gradient (not `MeditationScreenGradients`):

- Light: `#5ba4e6` → `#38a3a5`
- Dark: `#6f86d6` → `#48c6ef`

## Meditation detail duration chips

`DurationButton` in **`MeditationDetailsView.swift`** implements reference-style cards (rounded rect, shadows, borders) per theme (Calm light, Sleep, Focus, Stress Relief, Energy, Gratitude, Calm dark, etc.).

- Reference style: `brandDurationDigit` + `brandDurationMinLabel` with tracking.
- Fallback: `brandNumber` + `brandCaption`.

## Other UI notes (non-exhaustive)

- **Home** uses liquid-glass card backgrounds (`LiquidGlassCardBackground`, `ThemeIconBloom`).
- **Mood check-in** uses a custom header mark (`MoodCheckInHeaderMark`) and a 4×2 mood grid.
- **Background sound cards** use a `checkmark.circle.fill` badge for selection (not only a ring).
- **Preview** pills on sound cards have stronger contrast in dark mode (fill + outline).
