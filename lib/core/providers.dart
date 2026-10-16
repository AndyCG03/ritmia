import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/firebase_repository.dart';
import '../data/local_repository.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import 'environment.dart';
final preferencesProvider = FutureProvider((ref) => SharedPreferences.getInstance());
final authProvider = StreamProvider<User?>((ref) => Environment.cloud
  ? FirebaseAuth.instance.authStateChanges() : Stream.value(null));
final repositoryProvider = Provider<SubscriptionRepository?>((ref) {
  if (Environment.cloud) {
    final user = ref.watch(authProvider).asData?.value;
    if (user == null) return null;
    final repository = FirebaseSubscriptionRepository(user.uid);
    ref.onDispose(repository.dispose); return repository;
  }
  final preferences = ref.watch(preferencesProvider).asData?.value;
  if (preferences == null) return null;
  final repository = LocalRepository(preferences);
  ref.onDispose(repository.dispose); return repository;
});
final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) =>
  ref.watch(repositoryProvider)?.watch() ?? const Stream.empty());
final entitlementProvider = StreamProvider<Entitlement>((ref) =>
  ref.watch(repositoryProvider)?.watchEntitlement() ?? const Stream.empty());
final logoProvider = FutureProvider.autoDispose.family<Uint8List?, Subscription>((ref, item) =>
  ref.watch(repositoryProvider)?.loadLogo(item) ?? Future.value(null));
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(preferencesProvider).asData?.value.getString('locale');
    return code == null ? null : Locale(code);
  }
  Future<void> setLocale(Locale? locale) async {
    final prefs = await ref.read(preferencesProvider.future);
    if (locale == null) { await prefs.remove('locale'); } else { await prefs.setString('locale', locale.languageCode); }
    state = locale;
  }
}
final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
/// Follows the phone by default; Settings can force light or dark.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final name = ref.watch(preferencesProvider).asData?.value.getString('themeMode');
    return ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);
  }
  Future<void> set(ThemeMode mode) async {
    final prefs = await ref.read(preferencesProvider.future);
    await prefs.setString('themeMode', mode.name);
    state = mode;
  }
}
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
