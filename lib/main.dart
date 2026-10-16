import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/environment.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  if (Environment.cloud) {
    try { await Firebase.initializeApp(options: Environment.firebaseOptions); }
    catch (_) { startupError = 'Firebase configuration is missing or invalid. See docs/FIREBASE.md.'; }
  }
  runApp(ProviderScope(child: RitmiaApp(startupError: startupError)));
}
