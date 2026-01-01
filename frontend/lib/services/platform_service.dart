import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

enum TvPlatform { webos, tizen, web, unknown }

class PlatformService {
  static TvPlatform? _cachedPlatform;

  /// Detect the current TV platform based on user agent
  static TvPlatform detectPlatform() {
    if (_cachedPlatform != null) return _cachedPlatform!;

    if (!kIsWeb) {
      _cachedPlatform = TvPlatform.unknown;
      return _cachedPlatform!;
    }

    try {
      final userAgent = web.window.navigator.userAgent;

      // Check for LG WebOS
      // Example: "Mozilla/5.0 (Web0S; Linux/SmartTV) ..."
      if (userAgent.contains('webOS') || userAgent.contains('Web0S')) {
        _cachedPlatform = TvPlatform.webos;
        return _cachedPlatform!;
      }

      // Check for Samsung Tizen
      // Example: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.5) ..."
      if (userAgent.contains('Tizen') || userAgent.contains('SMART-TV')) {
        _cachedPlatform = TvPlatform.tizen;
        return _cachedPlatform!;
      }

      _cachedPlatform = TvPlatform.web;
      return _cachedPlatform!;
    } catch (e) {
      _cachedPlatform = TvPlatform.web;
      return _cachedPlatform!;
    }
  }

  /// Check if running on a TV platform (WebOS or Tizen)
  static bool get isTvPlatform {
    final platform = detectPlatform();
    return platform == TvPlatform.webos || platform == TvPlatform.tizen;
  }

  /// Check if running on LG WebOS
  static bool get isWebOS => detectPlatform() == TvPlatform.webos;

  /// Check if running on Samsung Tizen
  static bool get isTizen => detectPlatform() == TvPlatform.tizen;

  /// Get platform name for display
  static String get platformName {
    switch (detectPlatform()) {
      case TvPlatform.webos:
        return 'LG WebOS';
      case TvPlatform.tizen:
        return 'Samsung Tizen';
      case TvPlatform.web:
        return 'Web Browser';
      case TvPlatform.unknown:
        return 'Unknown';
    }
  }
}
