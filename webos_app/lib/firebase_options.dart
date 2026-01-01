import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase configuration for the Downstream app.
///
/// To configure Firebase:
/// 1. Create a Firebase project at https://console.firebase.google.com
/// 2. Add a web app to your project
/// 3. Copy the configuration values below
/// 4. Or run `flutterfire configure` to generate this file automatically
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2F5V3YV8RNDTXdVyp7t654W72TeSdgWQ',
    appId: '1:482686216746:web:ff188b73bd4df1e26e3153',
    messagingSenderId: '482686216746',
    projectId: 'downstream-181e2',
    authDomain: 'downstream-181e2.firebaseapp.com',
    storageBucket: 'downstream-181e2.firebasestorage.app',
  );
}
