import 'dart:convert';
import 'package:http/http.dart' as http;

class OmdbService {
  static const String _baseUrl = 'https://www.omdbapi.com';

  final String apiKey;

  OmdbService({required this.apiKey});

  Future<OmdbMovie?> getMovie(String imdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?apikey=$apiKey&i=$imdbId'),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['Response'] == 'False') {
        return null;
      }

      return OmdbMovie.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

class OmdbMovie {
  final String imdbId;
  final String title;
  final String? year;
  final String? rated;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? plot;
  final String? poster;
  final String? imdbRating;

  OmdbMovie({
    required this.imdbId,
    required this.title,
    this.year,
    this.rated,
    this.runtime,
    this.genre,
    this.director,
    this.plot,
    this.poster,
    this.imdbRating,
  });

  factory OmdbMovie.fromJson(Map<String, dynamic> json) {
    return OmdbMovie(
      imdbId: json['imdbID'] as String,
      title: json['Title'] as String? ?? 'Unknown',
      year: json['Year'] as String?,
      rated: json['Rated'] as String?,
      runtime: json['Runtime'] as String?,
      genre: json['Genre'] as String?,
      director: json['Director'] as String?,
      plot: json['Plot'] as String?,
      poster: _cleanPoster(json['Poster'] as String?),
      imdbRating: json['imdbRating'] as String?,
    );
  }

  static String? _cleanPoster(String? poster) {
    if (poster == null || poster == 'N/A') return null;
    return poster;
  }

  int? get runtimeMinutes {
    if (runtime == null || runtime == 'N/A') return null;
    final match = RegExp(r'(\d+)').firstMatch(runtime!);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  double? get rating {
    if (imdbRating == null || imdbRating == 'N/A') return null;
    return double.tryParse(imdbRating!);
  }

  String get formattedRuntime {
    final mins = runtimeMinutes;
    if (mins == null) return '';
    final hours = mins ~/ 60;
    final minutes = mins % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
