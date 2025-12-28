# Firestore Schema

Shared contract between downstream-web and downstream-cli.

## Collection: `requests`

Media download requests. Created by web app, processed by CLI.

**Document ID**: `{mediaType}_{tmdbId}` (e.g., `movie_550`, `tv_1399`)

| Field | Type | Set By | Description |
| ------- | ------ | -------- | ------------- |
| `tmdbId` | integer | web | TMDB ID of the movie or TV show |
| `mediaType` | string | web | `"movie"` or `"tv"` |
| `title` | string | web | Display title |
| `posterPath` | string? | web | TMDB poster path (e.g., `/abc123.jpg`) |
| `requestedBy` | string | web | Firebase user ID |
| `requestedAt` | timestamp | web | When request was created |
| `status` | string | both | Current processing status (see below) |
| `downloadProgress` | double? | CLI | 0.0–1.0 during download |
| `transcodingProgress` | double? | CLI | 0.0–1.0 during transcoding |
| `uploadProgress` | double? | CLI | 0.0–1.0 during upload |
| `downloadStartedAt` | timestamp? | CLI | When download began |
| `transcodingStartedAt` | timestamp? | CLI | When transcoding began |
| `uploadStartedAt` | timestamp? | CLI | When upload began |
| `storagePath` | string? | CLI | B2/CDN path when complete |
| `errorMessage` | string? | CLI | Error details if failed |
| `torrentName` | string? | CLI | Name of selected torrent |
| `torrentId` | integer? | CLI | Transmission torrent ID (temporary) |
| `year` | string? | CLI | Release year (extracted from torrent) |

### Status Values

| Status | Set By | Meaning |
| -------- | -------- | --------- |
| `pending` | web | Awaiting pickup by CLI |
| `downloading` | CLI | Torrent active in Transmission |
| `transcoding` | CLI | FFmpeg converting to HLS |
| `uploading` | CLI | Uploading HLS segments to B2 |
| `available` | CLI | Complete, ready to stream |
| `failed` | CLI | Error occurred (see `errorMessage`) |

### Status Transitions

```text
pending → downloading → transcoding → uploading → available
    ↓          ↓             ↓            ↓
    └──────────┴─────────────┴────────────┴──→ failed
```

Web app can reset `failed` → `pending` via `/api/requests/{type}/{id}/reset`.

---

## Collection: `users/{userId}/watched`

User watch history. Used only by web app.

**Document ID**: `{mediaType}_{tmdbId}`

| Field | Type | Description |
| ------- | ------ | ------------- |
| `tmdbId` | integer | TMDB ID |
| `mediaType` | string | `"movie"` or `"tv"` |
| `watchedAt` | timestamp | When marked as watched |
