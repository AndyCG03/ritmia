import 'package:firebase_core/firebase_core.dart';

abstract final class Environment {
  static const cloud = bool.fromEnvironment('FIREBASE_ENABLED');
  static FirebaseOptions get firebaseOptions {
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    if ([projectId, apiKey, appId, sender].any((v) => v.isEmpty)) {
      throw StateError('Missing Firebase options');
    }
    return const FirebaseOptions(
      apiKey: apiKey, appId: appId, messagingSenderId: sender, projectId: projectId,
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      iosBundleId: 'app.ritmia.ritmia',
    );
  }
}
