# InkTime

InkTime is a clean, distraction-free e-ink inspired dashboard that combines a large 24-hour clock, local weather, forecasts, air quality, sun details, and world clocks in one elegant monochrome interface. Designed for Android and iOS, InkTime focuses on clarity, simplicity, and useful information at a glance.

**Features**

- Large 24-hour digital clock with local date and timezone
- GPS weather lookup or manual city search
- Current temperature, feels-like temperature, humidity, wind, pressure, precipitation, and UV index
- Hourly forecast and 5-day weather forecast
- Air quality, PM2.5, PM10, and pollen information where available
- Sunrise, sunset, and daylight duration details
- Saved world clocks with automatic timezone support
- E-ink friendly light and dark themes
- Pull-to-refresh dashboard and forecast screens
- Clean monochrome design optimized for readability
- Metric units throughout: °C, km/h, hPa, mm, and µg/m³
- No paid weather API or API key required

InkTime uses Open-Meteo services for weather, forecast, air quality, and geocoding data, delivering reliable information without unnecessary complexity. The app only uses location access to display local weather and does not continuously track your location.

Whether you want a calm bedside clock, a focused desk dashboard, or a minimalist weather companion, InkTime delivers essential information in a beautiful e-ink inspired experience.

**Internal package name:** `e_ink_clock` (see `pubspec.yaml`). Stores and launches show **InkTime**.

## Repository layout

| Path | Contents |
| --- | --- |
| `lib/` | Application logic and UI |
| `android/` | Android packaging |
| `ios/` | iOS packaging |
| `assets/icon/` | Source artwork for icons and listing graphics |
| `metadata/google_play/en-US/screenshots/` | Play Store phone / tablet screenshots |

## App icon

- `assets/icon/app_icon.svg` — editable master SVG
- `assets/icon/app_icon_foreground.svg` — Android adaptive foreground SVG
- `assets/icon/app_icon.png` — 1024×1024 master PNG (cream background)
- `assets/icon/app_icon_foreground.png` — transparent foreground for adaptive icon
- `assets/icon/play_store_icon.png` — 512×512 Play listing asset
- `assets/icon/app_store_icon.png` — 1024×1024 App Store marketing icon
- Android launcher bitmaps under `android/app/src/main/res/mipmap-*`
- iOS AppIcon set under `ios/Runner/Assets.xcassets/AppIcon.appiconset`

Regenerate Android and iOS launcher icons from the master PNG:

```powershell
dart run flutter_launcher_icons
```

## Data sources

- Open-Meteo Forecast API: `https://api.open-meteo.com/v1/forecast`
- Open-Meteo Air Quality API: `https://air-quality-api.open-meteo.com/v1/air-quality`
- Open-Meteo Geocoding API: `https://geocoding-api.open-meteo.com/v1/search`
- Device location and reverse place labels use platform location services exposed to the app (no continuous background tracking).

## Required permissions

**Android**

- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.INTERNET`

**iOS**

- `NSLocationWhenInUseUsageDescription` — “This app uses your location to show local weather.”

## Google Play release checklist

1. **Application ID.** This repo uses `app.inktime` for Android `namespace` / `applicationId` and as the iOS bundle id in `ios/Runner/Info.plist`. Confirm or replace before a public release.
2. **Signing.** Configure a release keystore (see comments in `android/app/build.gradle.kts` and `android/key.properties.example`).
3. **Version.** Bump `version` in `pubspec.yaml`; increment the build number for every Play upload.
4. **Bundle output path (typical):** `build/app/outputs/bundle/release/app-release.aab`
5. **Listing.** Upload icon from `assets/icon/app_icon.png`, add screenshots from `metadata/google_play/en-US/screenshots/`, and enter store copy in Play Console.

## iOS release

Produce a signed release archive from macOS with Xcode installed, then complete App Store Connect metadata in the portal.

## Troubleshooting

- **Location denied** — Enable location in system settings; permanent denial requires changing it outside the app.
- **Network / APIs** — Check connectivity, firewalls, and Open-Meteo availability; errors are shown in-app.
- **Pollen unavailable** — Open-Meteo pollen is region- and season-dependent; the UI shows “Unavailable” when no data is returned.

Technical contributors are expected to use the standard Flutter Material toolchain for this project type: dependency sync, static checks, and store builds. Use the ecosystem’s diagnostics when environment or SDK paths are misconfigured.
