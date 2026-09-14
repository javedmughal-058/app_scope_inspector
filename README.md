# AppScope - Inspector

A Flutter UI and native Android method-channel app inspector, using Provider and Clean Architecture.

## Included screens

- Splash
- Home dashboard
- Installed Apps
- Filters & Sort
- App Details
- Quick Tools
- Statistics
- Developer
- About Evolix
- Settings / Theme

## Font

The UI is designed for Inter. Font files are intentionally not redistributed in this archive.
Download the official Inter family and place these files in `assets/fonts/`:

- Inter-Regular.ttf (400)
- Inter-Medium.ttf (500)
- Inter-SemiBold.ttf (600)
- Inter-Bold.ttf (700)
- Inter-ExtraBold.ttf (800)

Then add the font section to `pubspec.yaml` if you want bundled Inter instead of platform fallback.

## Android package visibility

For complete installed-app visibility, Android requires `QUERY_ALL_PACKAGES`.
Review and justify this permission under Google Play policy before a production Play Store release.

Example manifest declaration:

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

## Running

This archive intentionally contains the application source rather than generated Flutter platform folders.
Create or use an existing Flutter project, copy `lib/`, `assets/`, and the dependency entries from this `pubspec.yaml`, then run your normal Flutter commands manually.

See `AGENT.md` for project-wide coding rules.
