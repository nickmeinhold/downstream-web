import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'platform_service.dart';

class AuthService extends ChangeNotifier {
  // Only initialize Firebase auth if not on TV platform
  FirebaseAuth? _auth;
  // Only create GoogleSignIn for non-web platforms
  GoogleSignIn? _googleSignIn;

  User? _user;
  bool _isLoading = true;
  String? _idToken;
  final bool _isTvMode;

  User? get user => _user;
  bool get isAuthenticated => _isTvMode || _user != null;
  bool get isLoading => _isLoading;
  String get username => _isTvMode ? 'TV User' : (_user?.displayName ?? _user?.email ?? '');
  String? get photoUrl => _isTvMode ? null : _user?.photoURL;
  String? get email => _isTvMode ? null : _user?.email;

  String get baseUrl {
    // For local development, always use localhost:8080
    // In production (Cloud Run), use same origin
    const isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction && kIsWeb) {
      return ''; // Same origin in production
    }
    return 'http://localhost:8080';
  }

  AuthService() : _isTvMode = PlatformService.isTvPlatform {
    if (!_isTvMode) {
      _auth = FirebaseAuth.instance;
      _googleSignIn = kIsWeb ? null : GoogleSignIn();
      _init();
    } else {
      // On TV, skip auth - just mark as ready
      _isLoading = false;
    }
  }

  Future<void> _init() async {
    if (_auth == null) return;

    // Set persistence to LOCAL (survives browser restarts)
    if (kIsWeb) {
      await _auth!.setPersistence(Persistence.LOCAL);
    }

    // Listen to auth state changes
    _auth!.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      _idToken = null; // Clear cached token on auth change
      notifyListeners();
    });
  }

  /// Get current ID token for API requests
  Future<String?> getIdToken() async {
    if (_isTvMode) return null; // No auth on TV
    if (_user == null) return null;
    // Get fresh token (Firebase caches and refreshes automatically)
    _idToken = await _user!.getIdToken();
    return _idToken;
  }

  /// Attempt to restore session (Firebase handles this automatically)
  Future<void> tryRestoreSession() async {
    if (_isTvMode) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    // Firebase Auth persists sessions automatically
    // Just wait for the auth state to settle
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  /// Sign in with Google
  Future<String?> signInWithGoogle() async {
    if (_isTvMode) return 'Auth not available on TV';
    if (_auth == null) return 'Auth not initialized';

    try {
      if (kIsWeb) {
        // Web flow - use popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth!.signInWithPopup(googleProvider);
        return null;
      } else {
        // Mobile flow
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) {
          return 'Sign in cancelled';
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth!.signInWithCredential(credential);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed';
    } catch (e) {
      return 'Sign in failed: $e';
    }
  }

  /// Sign out
  Future<void> logout() async {
    if (_isTvMode) return; // No auth on TV
    await _googleSignIn?.signOut();
    await _auth?.signOut();
  }
}
