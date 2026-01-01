import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import 'omdb_service.dart';

class B2Service {
  final String manifestUrl;
  final OmdbService? omdbService;
  late final String baseUrl;

  B2Service({required this.manifestUrl, this.omdbService}) {
    final uri = Uri.parse(manifestUrl);
    final pathSegments = uri.pathSegments.toList();
    if (pathSegments.isNotEmpty) {
      pathSegments.removeLast();
    }
    baseUrl = '${uri.scheme}://${uri.host}/${pathSegments.join('/')}';
  }

  Future<List<Video>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(manifestUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load manifest: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final entries = data['entries'] as Map<String, dynamic>?;
      if (entries == null) {
        throw Exception('No entries found in manifest');
      }

      final videos = <Video>[];
      for (final entry in entries.entries) {
        final entryData = entry.value as Map<String, dynamic>;
        final imdbId = entryData['imdbId'] as String?;

        // Fetch OMDB data if imdbId is available
        OmdbMovie? omdbData;
        if (omdbService != null && imdbId != null) {
          omdbData = await omdbService!.getMovie(imdbId);
        }

        final video = Video.fromManifestEntry(
          entry.key,
          entryData,
          baseUrl,
          omdbData: omdbData,
        );
        videos.add(video);
      }

      return videos;
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
