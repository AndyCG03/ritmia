import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import 'environment.dart';
import 'providers.dart';
import 'supported_languages.dart';
final notificationPermissionProvider = Provider<NotificationPermissionGateway>((ref) => NotificationService.instance);

class AlertController extends Notifier<bool>{
  @override
  bool build()=>ref.watch(preferencesProvider).asData?.value.getBool('deviceAlerts')??false;
  Future<PermissionOutcome> setEnabled(bool enabled)async{
    final prefs=await ref.read(preferencesProvider.future);
    await prefs.setBool('deviceAlertsRequested', enabled);
    if(enabled){
      final outcome=await ref.read(notificationPermissionProvider).requestPermission();
      if(outcome!=PermissionOutcome.granted)return outcome;
    }
    await prefs.setBool('deviceAlerts',enabled);
    state=enabled;
    ref.invalidate(systemBlockedProvider);
    return PermissionOutcome.granted;
  }
  /// Returning from Android settings completes an earlier request, but respects an explicit opt-out.
  Future<void> reconcile() async {
    final prefs = await ref.read(preferencesProvider.future);
    final wanted = prefs.getBool('deviceAlertsRequested') ?? state;
    if (!wanted || !ref.read(notificationPermissionProvider).supported) return;
    if (await ref.read(notificationPermissionProvider).enabledInSystem()) {
      await prefs.setBool('deviceAlerts', true);
      state = true;
    }
    ref.invalidate(systemBlockedProvider);
  }
}
final deviceAlertsProvider=NotifierProvider<AlertController,bool>(AlertController.new);
final reminderSyncProvider=FutureProvider<void>((ref)async{
  final items=ref.watch(subscriptionsProvider).asData?.value??[];
  final enabled=ref.watch(deviceAlertsProvider);
  final user=ref.watch(authProvider).asData?.value;
  final locale=ref.watch(localeProvider)??WidgetsBinding.instance.platformDispatcher.locale;
  await NotificationService.instance.sync(items,enabled&&(!Environment.cloud||user!=null),supportedLocale(locale));
});
/// True when the user enabled reminders but the OS later revoked the permission.
final systemBlockedProvider=FutureProvider.autoDispose<bool>((ref)async{
  if(!ref.watch(deviceAlertsProvider)||!ref.watch(notificationPermissionProvider).supported)return false;
  return !await ref.watch(notificationPermissionProvider).enabledInSystem();
});
