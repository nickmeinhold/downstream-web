import 'package:flutter/foundation.dart';

/// Stub AuthService for Tizen TV - no authentication required
/// TV platforms skip auth since popup-based flows don't work
class AuthService extends ChangeNotifier {
  static const _productionUrl = 'https://downstream-server-482686216746.us-central1.run.app';
  static const _devUrl = 'http://localhost:8080';

  final bool _isLoading = false;
  final bool _isAuthenticated = true; // Always authenticated on TV

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get idToken => null;
  String get userEmail => 'TV User';
  String get username => 'TV User';
  String? get photoUrl => null;
  String? get email => 'tv@downstream.app';

  // Use localhost in debug mode, Cloud Run in release
  String get baseUrl => kDebugMode ? _devUrl : _productionUrl;

  Future<String?> getIdToken() async => null;

  Future<void> tryRestoreSession() async {
    // No-op on TV
  }

  Future<bool> signInWithGoogle() async {
    // No-op on TV
    return true;
  }

  Future<void> signOut() async {
    // No-op on TV
  }

  Future<void> logout() async {
    // No-op on TV
  }
}
