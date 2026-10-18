import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/home_widget_service.dart';
import 'environment.dart';
import 'providers.dart';
import 'reminder_providers.dart';

final homeWidgetServiceProvider = Provider((ref) => HomeWidgetService());
final homeWidgetSyncProvider = FutureProvider<void>((ref) async {
  final data = ref.watch(subscriptionsProvider);
  final user = ref.watch(authProvider).asData?.value;
  final overrideLocale = ref.watch(localeProvider);
  final theme = ref.watch(themeModeProvider);
  final service = ref.watch(homeWidgetServiceProvider);
  // Loading must not erase the last known snapshot. Sign-out must erase it.
  if (Environment.cloud && user == null) {
    await service.sync([], overrideLocale ?? WidgetsBinding.instance.platformDispatcher.locale, overrideLocale: overrideLocale, theme: theme);
  } else if (data.isLoading || data.hasError) {
    return;
  } else if (data.asData case final value?) {
    await service.sync(value.value, overrideLocale ?? WidgetsBinding.instance.platformDispatcher.locale, overrideLocale: overrideLocale, theme: theme);
  }
});

/// One lifecycle owner reconciles permissions and refreshes snapshots after a day/timezone change.
final appLifecycleProvider = Provider<void>((ref) {
  Future<void> reconcile() async {
    try { await ref.read(deviceAlertsProvider.notifier).reconcile(); }
    catch (_) { /* Scheduling errors are surfaced in Settings; keep the app usable. */ }
    ref.invalidate(systemBlockedProvider);
    ref.invalidate(reminderSyncProvider);
    ref.invalidate(homeWidgetSyncProvider);
  }
  final listener = AppLifecycleListener(onResume: reconcile);
  ref.onDispose(listener.dispose);
});
