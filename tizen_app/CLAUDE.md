# Claude Code Context

## Project Overview

Downstream Tizen is a native Flutter application for Samsung Tizen Smart TVs. It shares code with the WebOS app (`../webos_app/`) but builds as a native app using flutter-tizen.

## Architecture

- **Platform**: Native Flutter via flutter-tizen (not Flutter Web)
- **State Management**: Provider (ChangeNotifier pattern)
- **Video Playback**: Stub implementation (TODO: video_player_tizen)
- **Deployment**: TPK packages via sdb

## Key Differences from WebOS/Web Version

| Aspect | WebOS/Web | Tizen |
|--------|-----------|-------|
| Build Tool | flutter build web | flutter-tizen build tpk |
| Runtime | JavaScript in browser | Native Dart AOT |
| Video | HLS.js | video_player_tizen (TODO) |
| Auth | Firebase (skipped on TV) | Stub (always authenticated) |
| Package | .ipk via ares-cli | .tpk via sdb |

## Key Services

### AuthService (`lib/services/auth_service.dart`)
- **Stub implementation** - always returns authenticated
- TV platforms skip auth (no popup support)
- Provides mock values for username, email, photoUrl

### PlatformService (`lib/services/platform_service.dart`)
- Always returns `TvPlatform.tizen`
- `isTvPlatform` always true

### VideoService, B2Service, ApiService
- Identical to WebOS/Web version
- Shared code, no modifications needed

## Build & Deploy

### Local Testing (macOS)
```bash
cd tizen_app
flutter run -d macos
```

### Build for Tizen TV
```bash
flutter-tizen build tpk -ptv
```

### Deploy to Samsung TV
```bash
# Enable Developer Mode on TV first (Apps > Settings > 12345)
sdb connect <TV_IP>
sdb devices
flutter-tizen install
flutter-tizen run
```

## Tizen SDK Setup

The Tizen SDK requires:
1. flutter-tizen from GitHub
2. Tizen Studio or VS Code Extension for Tizen
3. tizen-core package (requires Java 8-11)
4. .NET SDK 6.0+

Current status: flutter-tizen installed, but tizen-core not configured due to Java compatibility issues with the package manager.

## File Structure

```
lib/
├── main.dart                    # Tizen entry point (no Firebase)
├── config.dart                  # Shared config
├── constants.dart               # Request status constants
├── models/
│   └── video.dart               # Shared video model
├── screens/
│   ├── tv_home_screen.dart      # Main TV UI with tabs
│   └── tv_video_detail_screen.dart
├── services/
│   ├── api_service.dart         # TMDB + request API
│   ├── auth_service.dart        # STUB - always authenticated
│   ├── b2_service.dart          # B2 manifest loading
│   ├── omdb_service.dart        # OMDB metadata
│   ├── platform_service.dart    # Always returns Tizen
│   └── video_service.dart       # Video state management
└── widgets/
    ├── hls_video_player.dart    # STUB - placeholder UI
    └── tv/
        ├── focusable_card.dart
        ├── tv_keyboard_handler.dart
        ├── tv_video_card.dart
        └── tv_video_row.dart
```

## Common Issues

**flutter-tizen doctor shows Tizen toolchain error**
- Need to install tizen-core package via Tizen Package Manager
- Requires Java 8-11 (not 17+) due to JAXB dependency

**Socket exception on macOS**
- Add `com.apple.security.network.client` to entitlements:
  - `macos/Runner/DebugProfile.entitlements`
  - `macos/Runner/Release.entitlements`

**Layout overflow on smaller screens**
- TV screens are designed for 1920x1080
- Some Row widgets may overflow on smaller macOS windows
- Not an issue on actual TV hardware

## TODO

- [ ] Install tizen-core (needs Java 8 or VS Code Extension)
- [ ] Implement video_player_tizen for actual playback
- [ ] Test on physical Samsung TV
- [ ] Handle Samsung remote-specific key codes
