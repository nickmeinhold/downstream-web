# Downstream Tizen

A Flutter application for Samsung Tizen Smart TVs, sharing code with the WebOS/Web version.

## Features

- **Library**: Browse your video collection in Netflix-style horizontal rows grouped by genre
- **New Releases**: Discover new movies and TV shows from TMDB
- **Trending**: See what's trending today or this week
- **Search**: Search TMDB and request downloads
- **Queue**: Track download/transcode progress

## Prerequisites

- Flutter SDK (3.x+)
- flutter-tizen (`git clone https://github.com/flutter-tizen/flutter-tizen.git`)
- Tizen SDK (via VS Code Extension for Tizen or Tizen Studio)
- .NET SDK 6.0+
- Samsung TV in Developer Mode (for deployment)

## Setup

### 1. Install flutter-tizen

```bash
git clone https://github.com/flutter-tizen/flutter-tizen.git ~/flutter-tizen
echo 'export PATH="$HOME/flutter-tizen/bin:$PATH"' >> ~/.zshrc
echo 'export TIZEN_SDK="$HOME/tizen-studio"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Install Tizen SDK

Install via VS Code Extension for Tizen (recommended) or download from:
https://developer.tizen.org/development/tizen-studio/download

### 3. Verify Setup

```bash
flutter-tizen doctor
```

## Development

### Run Locally (macOS)

```bash
flutter run -d macos
```

### Build for Tizen TV

```bash
flutter-tizen build tpk -ptv
```

### Deploy to Samsung TV

1. **Enable Developer Mode on TV**:
   - Go to Apps > Settings (gear icon)
   - Enter `12345` on the remote
   - Enable Developer Mode
   - Enter your computer's IP address
   - Restart the TV

2. **Connect to TV**:
   ```bash
   sdb connect <TV_IP_ADDRESS>
   sdb devices
   ```

3. **Install and Run**:
   ```bash
   flutter-tizen install
   flutter-tizen run
   ```

## Project Structure

```
tizen_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config.dart            # API keys, manifest URL
│   ├── constants.dart         # Request status constants
│   ├── models/
│   │   └── video.dart         # Video model
│   ├── screens/
│   │   ├── tv_home_screen.dart
│   │   └── tv_video_detail_screen.dart
│   ├── services/
│   │   ├── api_service.dart   # TMDB API
│   │   ├── auth_service.dart  # Stub (no auth on TV)
│   │   ├── b2_service.dart    # B2 manifest loading
│   │   ├── omdb_service.dart  # OMDB metadata
│   │   ├── platform_service.dart
│   │   └── video_service.dart
│   └── widgets/
│       ├── hls_video_player.dart  # Video player (stub)
│       └── tv/                    # TV-specific widgets
├── macos/                     # macOS runner (for local testing)
├── tizen/
│   ├── tizen-manifest.xml     # Tizen app manifest
│   └── shared/res/            # App icons
└── pubspec.yaml
```

## Shared Code

This app shares most of its code with the WebOS app at `../webos_app/`. Key differences:

| Component | WebOS/Web | Tizen |
|-----------|-----------|-------|
| Platform | Flutter Web (JS) | Native Flutter |
| Video Player | HLS.js | video_player_tizen (TODO) |
| Auth | Firebase (optional) | Stub (always authenticated) |
| Package Format | .ipk | .tpk |

## Navigation

- **D-pad arrows**: Navigate between items
- **Enter/OK**: Select
- **Back**: Go back

## TODO

- [ ] Implement video_player_tizen for actual video playback
- [ ] Configure Tizen SDK packages (tizen-core)
- [ ] Test on physical Samsung TV
- [ ] Add TV-specific remote key handling
