# Claude Code Context

## Project Overview

Downstream WebOS is a Flutter Web application optimized for LG WebOS Smart TVs. It provides a Netflix-style interface for browsing a personal video library and requesting new content downloads.

## Architecture

- **Platform**: Flutter Web (JavaScript build, not WASM - WebOS doesn't support WASM)
- **State Management**: Provider (ChangeNotifier pattern)
- **Video Playback**: HLS.js for adaptive streaming
- **Deployment**: WebOS IPK packages via ares-cli

## Key Services

### VideoService (`lib/services/video_service.dart`)
- Wraps B2Service to load videos from the B2 manifest
- Groups videos by genre for Netflix-style rows
- Provides `videosByGenre`, `videosSortedByRating`

### B2Service (`lib/services/b2_service.dart`)
- Fetches video manifest from B2 CDN
- Parses manifest entries into Video models
- Uses OmdbService to enrich metadata

### AuthService (`lib/services/auth_service.dart`)
- Firebase Auth with Google Sign-In (web popup flow)
- **TV Mode**: Skips Firebase entirely (popup auth doesn't work on WebOS)
- Detects TV platform via `PlatformService.isTvPlatform`

### ApiService (`lib/services/api_service.dart`)
- TMDB integration for browsing new releases, trending, search
- Request management (create, list, retry)
- Requires backend server running

### PlatformService (`lib/services/platform_service.dart`)
- Detects WebOS via user agent (`webOS` or `Web0S`)
- `isTvPlatform` boolean for conditional behavior

## Build & Deploy

### Local Development
```bash
cd webos_app
flutter run -d chrome
```

### Build for WebOS
```bash
flutter build web --release
# Fix base href for file:// protocol
sed -i '' 's|<base href="/">|<base href="./">|' build/web/index.html
sed -i '' 's|<body>|<body tabindex="0">|' build/web/index.html
```

### Package & Install on TV
```bash
# Requires Node 18 (Node 25 has bugs with ares-cli)
nvm use 18
ares-package --no-minify build/web -o .
ares-install --device lgtv com.downstream.app_1.0.0_all.ipk
ares-launch --device lgtv com.downstream.app
```

### Debug on TV
```bash
ares-inspect --device lgtv --app com.downstream.app
# Opens Chrome DevTools for the app
```

## WebOS Compatibility Notes

1. **No WASM**: WebOS browser doesn't support Flutter's WASM build. Use `flutter build web` (not `--wasm`)

2. **Base href**: Must be `"./"` not `"/"` for file:// protocol to work

3. **Firebase/Auth**: Popup-based auth doesn't work. App detects TV mode and skips auth entirely

4. **Remote Control**:
   - Magic Remote pointer works (mouse events)
   - D-pad arrows need focus management (partially implemented)
   - Body needs `tabindex="0"` for key events

5. **Video Player**: HLS.js works fine. Positioned widgets must be direct children of Stack (not wrapped in AnimatedOpacity)

## File Structure

```
lib/
├── config.dart              # API keys, manifest URL
├── constants.dart           # Request status constants
├── main.dart                # App entry, providers, TV detection
├── models/
│   └── video.dart           # Video model from B2 manifest
├── screens/
│   ├── login_screen.dart    # Google Sign-In (non-TV only)
│   ├── tv_home_screen.dart  # Main TV UI with all tabs
│   └── tv_video_detail_screen.dart
├── services/
│   ├── api_service.dart     # TMDB + request API
│   ├── auth_service.dart    # Firebase auth (TV-safe)
│   ├── b2_service.dart      # B2 manifest loading
│   ├── omdb_service.dart    # OMDB metadata
│   ├── platform_service.dart # TV detection
│   └── video_service.dart   # Video state management
└── widgets/
    ├── hls_video_player.dart # HLS playback with controls
    └── tv/
        ├── focusable_card.dart
        ├── tv_keyboard_handler.dart
        ├── tv_video_card.dart
        └── tv_video_row.dart
```

## Common Issues

**Black screen on TV**: Check console for errors. Usually:
- Flutter not loading (base href issue)
- Firebase crash (auth not TV-safe)
- Layout exceptions (Positioned not direct child of Stack)

**ares-cli errors**: Use Node 18, not Node 25+

**No key events**: Ensure body has `tabindex="0"` and focus is on flt-glass-pane
