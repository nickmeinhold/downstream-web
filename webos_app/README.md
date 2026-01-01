# Downstream WebOS

A Flutter Web application for browsing and streaming your personal video library on LG WebOS Smart TVs.

## Features

- **Library**: Browse your video collection in Netflix-style horizontal rows grouped by genre
- **New Releases**: Discover new movies and TV shows from TMDB with filters (genre, rating, time period)
- **Trending**: See what's trending today or this week
- **Search**: Search TMDB and request downloads
- **Queue**: Track download/transcode progress, retry failed requests, play available content
- **Video Player**: HLS adaptive streaming with keyboard controls

## Prerequisites

- Flutter SDK (3.x+)
- Node.js 18.x (for WebOS deployment)
- LG WebOS TV in Developer Mode (for TV deployment)

### For full functionality:
- Backend server running (for TMDB browsing and requests)
- B2 storage with video manifest

## Quick Start

### Run in Browser

```bash
cd webos_app
flutter run -d chrome
```

### Run on LG WebOS TV

1. **Enable Developer Mode on TV**:
   - Install "Developer Mode" app from LG Content Store
   - Sign in with LG developer account
   - Enable Developer Mode and Key Server

2. **Set up ares-cli**:
   ```bash
   npm install -g @pnp/cli-microsoft365
   # Or use the webOS CLI from LG
   ```

3. **Register your TV**:
   ```bash
   ares-setup-device
   # Add device with TV's IP address
   ```

4. **Build and deploy**:
   ```bash
   flutter build web --release

   # Fix for WebOS file:// protocol
   sed -i '' 's|<base href="/">|<base href="./">|' build/web/index.html
   sed -i '' 's|<body>|<body tabindex="0">|' build/web/index.html

   # Package (use Node 18!)
   nvm use 18
   ares-package --no-minify build/web -o .

   # Install and launch
   ares-install --device lgtv com.downstream.app_1.0.0_all.ipk
   ares-launch --device lgtv com.downstream.app
   ```

5. **Debug** (optional):
   ```bash
   ares-inspect --device lgtv --app com.downstream.app
   # Opens Chrome DevTools connected to TV
   ```

## Configuration

Edit `lib/config.dart`:

```dart
class AppConfig {
  static const String manifestUrl = 'YOUR_B2_MANIFEST_URL';
  static const String omdbApiKey = 'YOUR_OMDB_API_KEY';
}
```

## Project Structure

```
webos_app/
├── lib/
│   ├── config.dart           # Configuration
│   ├── main.dart             # App entry point
│   ├── models/               # Data models
│   ├── screens/              # UI screens
│   ├── services/             # Business logic
│   └── widgets/              # Reusable widgets
├── build/
│   └── web/
│       └── appinfo.json      # WebOS app metadata
└── web/
    └── index.html            # Web entry point
```

## Navigation

### Magic Remote (LG)
- Point and click like a mouse
- Scroll wheel for scrolling

### D-Pad / Arrow Keys
- Arrow keys to move focus between items
- Enter/OK to select
- Back button to go back

### Video Player Controls
- Space/Enter: Play/Pause
- Left/Right arrows: Seek +/- 10 seconds
- Escape/Back: Exit player

## Technical Notes

### WebOS Compatibility

- Uses JavaScript build (not WASM) for WebOS browser compatibility
- Base href set to `"./"` for file:// protocol
- Firebase auth disabled on TV (no popup support)
- Body element needs `tabindex="0"` for keyboard events

### Video Playback

- HLS.js for adaptive streaming
- Supports .m3u8 playlist URLs
- Auto-hide controls after 3 seconds of inactivity

## Troubleshooting

**Black screen on TV**
- Check Chrome DevTools console via `ares-inspect`
- Ensure base href is `"./"` not `"/"`
- Verify Flutter loaded: `typeof _flutter` in console

**ares-cli "isDate is not a function" error**
- Use Node.js 18, not 25+
- `nvm use 18` before running ares commands

**Videos not loading**
- Check manifest URL is accessible
- Verify CORS headers on B2 bucket
- Check browser console for network errors

## Related Projects

- **downstream-cli**: Handles download, transcode, and upload workflow
- **downstream-web/server**: Backend API for TMDB and request management
