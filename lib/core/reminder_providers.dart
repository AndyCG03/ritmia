import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import 'environment.dart';
import 'providers.dart';
class AlertController extends Notifier<bool>{
  @override
  bool build()=>ref.watch(preferencesProvider).asData?.value.getBool('deviceAlerts')??false;
  Future<PermissionOutcome> setEnabled(bool enabled)async{
    if(enabled){
      final outcome=await NotificationService.instance.requestPermission();
      if(outcome!=PermissionOutcome.granted)return outcome;
    }
    final prefs=await ref.read(preferencesProvider.future);
    await prefs.setBool('deviceAlerts',enabled);
    state=enabled;return PermissionOutcome.granted;
  }
}
final deviceAlertsProvider=NotifierProvider<AlertController,bool>(AlertController.new);
final reminderSyncProvider=FutureProvider<void>((ref)async{
  final items=ref.watch(subscriptionsProvider).asData?.value??[];
  final enabled=ref.watch(deviceAlertsProvider);
  final user=ref.watch(authProvider).asData?.value;
  final locale=ref.watch(localeProvider)??WidgetsBinding.instance.platformDispatcher.locale;
  final supportedLocale=['es','en'].contains(locale.languageCode)?Locale(locale.languageCode):const Locale('en');
  await NotificationService.instance.sync(items,enabled&&(!Environment.cloud||user!=null),supportedLocale);
});
/// True when the user enabled reminders but the OS later revoked the permission.
final systemBlockedProvider=FutureProvider.autoDispose<bool>((ref)async{
  if(!ref.watch(deviceAlertsProvider)||!NotificationService.instance.supported)return false;
  return !await NotificationService.instance.enabledInSystem();
});
