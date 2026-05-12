# InkTime

InkTime is a Flutter + Dart e-ink inspired dashboard app for Android, iOS and Windows desktop development. It combines a large 24-hour clock, GPS weather, forecasts, sun details, air quality, pollen, pressure and saved world clocks in a muted monochrome interface.

## Features

- One Flutter/Dart codebase.
- Android, iOS and Windows desktop support.
- E-ink friendly light and dark modes.
- Large 24-hour digital clock.
- Local date, local timezone and nearest location label.
- One-shot GPS lookup only; no continuous location tracking.
- Open-Meteo weather with no paid API and no API key.
- Current temperature, feels-like temperature, high, low, humidity, wind, pressure, precipitation and precipitation probability.
- UV index, air quality, PM2.5, PM10 and pollen where Open-Meteo supports the region/season.
- Sunrise, sunset and daylight duration.
- Forecast tab with rest-of-day hourly forecast and next 5 days.
- Saved world clocks with Open-Meteo city search.
- World clocks sorted by current local time, with day offset labels.
- All times use 24-hour format.
- All units use metric/SI units: °C, mm, %, km/h, hPa and µg/m³.
- Graceful handling for denied location permission, unavailable GPS, failed network/API calls and malformed responses.

## Screenshots

Screenshots placeholder:

- Dashboard light mode
- Dashboard dark mode
- Forecast tab
- Add timezone search
- Location permission denied state

## APIs

InkTime uses:

- Open-Meteo Forecast API: `https://api.open-meteo.com/v1/forecast`
- Open-Meteo Air Quality API: `https://air-quality-api.open-meteo.com/v1/air-quality`
- Open-Meteo Geocoding API: `https://geocoding-api.open-meteo.com/v1/search`
- Device GPS through Flutter `geolocator`
- Reverse geocoding through Flutter `geocoding`

Open-Meteo is used because it is free for this use case, does not require API keys, supports metric units, and provides forecast, weather, air quality and geocoding data.

## Project Structure

```text
lib/
  main.dart
  app.dart
  shared/
  features/
    clock/
    weather/
    timezones/
assets/
  icon/
metadata/
  google_play/
docs/
```

## App Icon and Metadata

Icon source and generated launcher assets:

- `assets/icon/app_icon.svg`
- `assets/icon/app_icon.png`
- `assets/icon/app_icon_foreground.png`
- Android launcher PNGs under `android/app/src/main/res/mipmap-*`
- iOS AppIcon set under `ios/Runner/Assets.xcassets/AppIcon.appiconset`

Store and SEO metadata:

- `metadata/google_play/en-US/title.txt`
- `metadata/google_play/en-US/short_description.txt`
- `metadata/google_play/en-US/full_description.txt`
- `metadata/google_play/en-US/keywords.txt`
- `metadata/google_play/en-US/release_notes.txt`
- `docs/seo_metadata.md`

To regenerate launcher icons after changing `assets/icon/app_icon.png`:

```powershell
flutter pub get
dart run flutter_launcher_icons
```

## Required Permissions

Android:

- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.INTERNET`

iOS:

- `NSLocationWhenInUseUsageDescription`
- Value: `This app uses your location to show local weather.`

## Windows Setup

Install requirements:

1. Install Flutter SDK for Windows.
2. Add Flutter to PATH.
3. Install Android Studio.
4. Install Android SDK and emulator.
5. Install Visual Studio 2022 Build Tools.
6. In Visual Studio Installer, enable:
   - Desktop development with C++
   - Windows 10/11 SDK
   - MSVC build tools

Verify setup:

```powershell
flutter doctor
```

Install dependencies:

```powershell
flutter pub get
```

Run on Windows desktop:

```powershell
flutter run -d windows
```

## Android Development

List devices:

```powershell
flutter devices
```

Run on Android emulator or device:

```powershell
flutter run -d <device_id>
```

Run tests:

```powershell
flutter test
```

Analyze:

```powershell
flutter analyze
```

## Google Play Store Build and Publishing

1. Choose a final Android package name.

   Update `android/app/build.gradle.kts`:

   ```kotlin
   namespace = "com.a2js.inktime"
   applicationId = "com.a2js.inktime"
   ```

2. Generate an upload keystore.

   ```powershell
   New-Item -ItemType Directory -Force android\release
   keytool -genkey -v -keystore android\release\inktime-upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias inktime
   ```

3. Create `android/key.properties` from `android/key.properties.example`.

   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=inktime
   storeFile=../release/inktime-upload-keystore.jks
   ```

4. Configure release signing in `android/app/build.gradle.kts`.

   Add before `android { ... }`:

   ```kotlin
   import java.util.Properties
   import java.io.FileInputStream

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }
   ```

   Replace the release signing config with:

   ```kotlin
   signingConfigs {
       create("release") {
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }

   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
           isMinifyEnabled = false
           isShrinkResources = false
       }
   }
   ```

5. Update version in `pubspec.yaml`.

   ```yaml
   version: 1.0.0+1
   ```

   Increment the build number after every Play Store upload.

6. Build the Android App Bundle.

   ```powershell
   flutter clean
   flutter pub get
   flutter test
   flutter analyze
   flutter build appbundle --release
   ```

   Output:

   ```text
   build/app/outputs/bundle/release/app-release.aab
   ```

7. Create the app in Google Play Console.

   - App name: `InkTime`
   - Default language: English
   - App type: App
   - Category: Weather
   - Free or paid: choose before publishing

8. Complete Play Console setup.

   - Upload app icon from `assets/icon/app_icon.png`.
   - Add screenshots.
   - Use copy from `metadata/google_play/en-US`.
   - Complete Data safety.
   - Complete content rating.
   - Add privacy policy URL.
   - Upload the `.aab` to Internal testing first.
   - Test install from Play Store internal testing.
   - Promote to Closed testing, Open testing or Production when ready.

## iOS Notes

Run iOS builds from macOS with Xcode installed.

```bash
flutter pub get
flutter build ipa --release
```

Configure signing, bundle identifier and App Store Connect metadata in Xcode/App Store Connect.

## Troubleshooting

### Flutter doctor errors

Run:

```powershell
flutter doctor -v
```

Resolve missing Android SDK, Xcode, Visual Studio or PATH issues.

### Missing Visual Studio Build Tools

Install Visual Studio 2022 Build Tools and enable:

- Desktop development with C++
- Windows 10/11 SDK
- MSVC build tools

### Android emulator not appearing

Start an emulator from Android Studio Device Manager, then run:

```powershell
flutter devices
```

Check virtualization support if no emulator appears.

### Location permission denied

Enable location permission in system settings and tap refresh. If permission is permanently denied, Android and iOS require changing it in system settings.

### Network/API failure

Check internet access, firewall rules and Open-Meteo availability. The app keeps the UI usable and shows a clear error.

### Pollen unavailable

Open-Meteo pollen data is region and season dependent. InkTime shows `Unavailable` when pollen data is not returned for the current location.

### Windows desktop GPS limitation

Windows desktop devices often do not have GPS hardware or a configured location provider. Android and iOS devices provide the best GPS behavior.
