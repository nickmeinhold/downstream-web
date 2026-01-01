import 'dart:io';
import 'package:downstream/src/server/server.dart';

void main(List<String> arguments) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  // Check for static files path (built Flutter web app)
  String? staticPath;
  if (arguments.isNotEmpty) {
    staticPath = arguments.first;
  } else if (Platform.environment['STATIC_PATH'] != null) {
    staticPath = Platform.environment['STATIC_PATH'];
  } else if (await Directory('../webos_app/build/web').exists()) {
    staticPath = '../webos_app/build/web';
  }

  final server = DownstreamServer(
    port: port,
    staticPath: staticPath,
  );

  try {
    await server.start();
  } catch (e) {
    stderr.writeln('Failed to start server: $e');
    exit(1);
  }
}
