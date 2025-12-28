# Claude Code Context

## Project Overview

Downstream is a self-hosted web app for discovering new streaming content. Users can browse, search, track watched content, and request downloads.

## Architecture

- `frontend/` - Flutter Web app (WASM)
- `server/` - Dart backend using shelf

## Related Projects

**downstream-cli** (https://github.com/nickmeinhold/downstream-cli) handles the downloading workflow:
- Monitors Firestore via gRPC real-time listener for pending requests
- Uses Jackett to search for torrents
- Manages downloads via Transmission
- Transcodes to HLS and uploads to B2
- Updates request status as it progresses

## How They Relate

```
User browses in downstream-web
         ↓
Clicks "Request for Download"
         ↓
Request saved to Firestore (status: pending)
         ↓
downstream-cli receives update via gRPC stream (instant)
         ↓
Picks up request, downloads, transcodes, uploads
         ↓
Updates Firestore status → reflected in web app
```

## Shared Contract

See [SCHEMA.md](SCHEMA.md) for the Firestore schema shared between this project and downstream-cli.

Status constants are defined in:
- `server/lib/src/constants.dart`
- `frontend/lib/constants.dart`

## Environment Variables

Server requires (in `server/.env`):
- `TMDB_API_KEY` - Content discovery
- `FIREBASE_PROJECT_ID` - Auth and Firestore
- `FIREBASE_SERVICE_ACCOUNT` - Service account JSON (inline or path)
- `OMDB_API_KEY` - Optional, for IMDB/RT/Metacritic ratings

## Running Locally

```bash
# Server
cd server
set -a && source .env && set +a
dart run bin/server.dart

# Frontend (separate terminal)
cd frontend
flutter run -d chrome
```

## Workflow

Before committing, run the Dart analyzer on both frontend and server using the MCP tool.
