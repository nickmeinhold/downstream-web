import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/b2_service.dart';
import 'services/omdb_service.dart';
import 'services/video_service.dart';
import 'services/platform_service.dart';
import 'screens/login_screen.dart';
import 'screens/tv_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip Firebase on TV platforms (auth won't work)
  final isTv = PlatformService.isTvPlatform;
  if (!isTv) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize services
  final omdbService = OmdbService(apiKey: AppConfig.omdbApiKey);
  final b2Service = B2Service(
    manifestUrl: AppConfig.manifestUrl,
    omdbService: omdbService,
  );

  runApp(DownstreamApp(b2Service: b2Service, isTvMode: isTv));
}

class DownstreamApp extends StatelessWidget {
  final B2Service b2Service;
  final bool isTvMode;

  const DownstreamApp({
    super.key,
    required this.b2Service,
    this.isTvMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => VideoService(b2Service)),
        ProxyProvider<AuthService, ApiService>(
          update: (_, auth, _) => ApiService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Downstream',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        // Skip auth on TV platforms - Firebase/Google Sign-In won't work
        home: isTvMode ? const TvHomeScreen() : const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().tryRestoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isAuthenticated) {
          return const TvHomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
