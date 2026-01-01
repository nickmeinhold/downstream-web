import 'package:flutter/foundation.dart';
import '../models/video.dart';
import 'b2_service.dart';

class VideoService extends ChangeNotifier {
  final B2Service _b2Service;

  List<Video> _videos = [];
  bool _isLoading = false;
  String? _error;

  VideoService(this._b2Service);

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get all unique genres from the video library
  List<String> get availableGenres {
    final genres = <String>{};
    for (final video in _videos) {
      if (video.genre != null) {
        // Genres may be comma-separated, e.g., "Action, Adventure, Sci-Fi"
        for (final g in video.genre!.split(',')) {
          final trimmed = g.trim();
          if (trimmed.isNotEmpty) {
            genres.add(trimmed);
          }
        }
      }
    }
    final sorted = genres.toList()..sort();
    return sorted;
  }

  /// Get videos grouped by genre
  Map<String, List<Video>> get videosByGenre {
    final result = <String, List<Video>>{};

    for (final video in _videos) {
      if (video.genre != null) {
        for (final g in video.genre!.split(',')) {
          final genre = g.trim();
          if (genre.isNotEmpty) {
            result.putIfAbsent(genre, () => []).add(video);
          }
        }
      } else {
        // Videos without genre go into "Other"
        result.putIfAbsent('Other', () => []).add(video);
      }
    }

    return result;
  }

  /// Get videos sorted by title
  List<Video> get videosSortedByTitle {
    final sorted = List<Video>.from(_videos);
    sorted.sort((a, b) => a.title.compareTo(b.title));
    return sorted;
  }

  /// Get videos sorted by rating (highest first)
  List<Video> get videosSortedByRating {
    final sorted = List<Video>.from(_videos);
    sorted.sort((a, b) {
      final aRating = a.rating ?? 0;
      final bRating = b.rating ?? 0;
      return bRating.compareTo(aRating);
    });
    return sorted;
  }

  /// Filter videos by genre
  List<Video> filterByGenre(String genre) {
    return _videos.where((v) {
      if (v.genre == null) return false;
      return v.genre!.toLowerCase().contains(genre.toLowerCase());
    }).toList();
  }

  /// Load videos from B2 manifest
  Future<void> loadVideos() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _b2Service.fetchVideos();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _videos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh videos (clear cache and reload)
  Future<void> refresh() async {
    _videos = [];
    notifyListeners();
    await loadVideos();
  }
}
