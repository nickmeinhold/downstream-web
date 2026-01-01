import 'package:flutter/foundation.dart';

/// Stub AuthService for Tizen TV - no authentication required
/// TV platforms skip auth since popup-based flows don't work
class AuthService extends ChangeNotifier {
  final bool _isLoading = false;
  final bool _isAuthenticated = true; // Always authenticated on TV

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get idToken => null;
  String get userEmail => 'TV User';
  String get username => 'TV User';
  String? get photoUrl => null;
  String? get email => 'tv@downstream.app';
  String get baseUrl => 'https://downstream-server-482686216746.us-central1.run.app';

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
