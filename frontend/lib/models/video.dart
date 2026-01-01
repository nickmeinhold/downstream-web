import '../services/omdb_service.dart';

class Video {
  final String id;
  final String title;
  final String url;
  final String? thumbnail;
  final String? overview;
  final int? duration; // in minutes
  final int? tmdbId;
  final String? imdbId;
  final String? year;
  final double? rating;
  final String? genre;

  Video({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnail,
    this.overview,
    this.duration,
    this.tmdbId,
    this.imdbId,
    this.year,
    this.rating,
    this.genre,
  });

  factory Video.fromManifestEntry(
    String key,
    Map<String, dynamic> entry,
    String baseUrl, {
    OmdbMovie? omdbData,
  }) {
    final storagePath = entry['storagePath'] as String;
    final videoUrl = '$baseUrl/$storagePath/master.m3u8';

    final mediaKey = entry['mediaKey'] as String? ?? key;

    return Video(
      id: key,
      title: omdbData?.title ?? _formatTitle(mediaKey),
      url: videoUrl,
      thumbnail: omdbData?.poster,
      overview: omdbData?.plot,
      duration: omdbData?.runtimeMinutes,
      tmdbId: entry['tmdbId'] as int?,
      imdbId: entry['imdbId'] as String?,
      year: omdbData?.year,
      rating: omdbData?.rating,
      genre: omdbData?.genre,
    );
  }

  static String _formatTitle(String mediaKey) {
    return mediaKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get subtitle {
    final parts = <String>[];
    if (year != null) parts.add(year!);
    if (duration != null) parts.add(formattedDuration);
    if (rating != null) parts.add('${rating!.toStringAsFixed(1)}★');
    return parts.join(' • ');
  }
}
