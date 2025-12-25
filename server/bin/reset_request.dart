import 'dart:convert';
import 'dart:io';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run bin/reset_request.dart <mediaKey>');
    print('Example: dart run bin/reset_request.dart movie_51876');
    return;
  }

  final mediaKey = args[0];

  final envContent = File('.env').readAsStringSync();
  final match = RegExp(r"FIREBASE_SERVICE_ACCOUNT='(.+)'").firstMatch(envContent);
  if (match == null) {
    print('Could not find service account');
    return;
  }

  final serviceAccountJson = json.decode(match.group(1)!);
  final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
  final scopes = [FirestoreApi.datastoreScope];

  final client = await clientViaServiceAccount(credentials, scopes);
  final firestore = FirestoreApi(client);

  final projectId = 'downstream-181e2';
  final docPath = 'projects/$projectId/databases/(default)/documents/requests/$mediaKey';

  final newStatus = args.length > 1 ? args[1] : 'pending';

  try {
    await firestore.projects.databases.documents.patch(
      Document(
        fields: {
          'status': Value(stringValue: newStatus),
        },
      ),
      docPath,
      updateMask_fieldPaths: ['status'],
    );
    print('Set $mediaKey to $newStatus');
  } catch (e) {
    print('Error: $e');
  }

  client.close();
}
