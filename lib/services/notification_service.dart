import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../domain/reminder.dart';
import '../domain/subscription.dart';
import '../l10n/generated/app_localizations.dart';

/// Result of asking for notification permission, so the UI can explain each case.
enum PermissionOutcome { granted, denied, unsupported }

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  Future<void> _pending = Future.value();

  /// Subscription id from a tapped reminder; the home screen opens its detail sheet.
  final openedSubscription = ValueNotifier<String?>(null);

  static const _channelId = 'ritmia_renewals';
  static const _accent = Color(0xFF7251AF);

  bool get supported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    if (!supported) return;
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_ritmia'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false)),
      onDidReceiveNotificationResponse: (r) => openedSubscription.value = r.payload);
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) openedSubscription.value = launch!.notificationResponse?.payload;
  }

  /// Whether the OS currently lets Ritmia post notifications (Android 13+ can revoke it from Settings).
  Future<bool> enabledInSystem() async {
    if (!supported) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
    }
    final perms = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions();
    return perms?.isEnabled ?? false;
  }

  Future<PermissionOutcome> requestPermission() async {
    if (!supported) return PermissionOutcome.unsupported;
    await initialize();
    final bool ok;
    if (defaultTargetPlatform == TargetPlatform.android) {
      ok = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    } else {
      ok = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return ok ? PermissionOutcome.granted : PermissionOutcome.denied;
  }

  String _money(int minor, String currency, String tag) => '${NumberFormat.decimalPatternDigits(locale: tag,
    decimalDigits: currencyDigits(currency)).format(minor / (currencyDigits(currency) == 0 ? 1 : 100))} $currency';

  Future<void> sync(List<Subscription> items, bool enabled, Locale locale) {
    final task = _pending.then((_) async {
      if (!supported) return;
      await initialize();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.cancelAllPendingNotifications();
      if (!enabled) return;
      final s = await AppLocalizations.delegate.load(locale);
      final tag = locale.toLanguageTag();
      final events = upcomingReminders(items, DateTime.now()).take(60).toList();
      // Rebuilding the complete bounded schedule permits collision-free sequential IDs.
      for (var i = 0; i < events.length; i++) {
        final e = events[i], sub = e.subscription, d = e.date;
        final when = e.leadDays == 0 ? s.notifToday : e.leadDays == 1 ? s.notifTomorrow : s.notifInDays(e.leadDays);
        final title = switch (e.kind) {
          ReminderKind.renewal => s.notifRenewalTitle(sub.name, when),
          ReminderKind.trial => s.notifTrialTitle(sub.name, when),
          ReminderKind.ending => s.notifEndingTitle(sub.name, when),
        };
        final day = DateFormat.MMMMEEEEd(tag).format(e.target);
        final amount = sub.free ? s.free : _money(sub.amountMinor, sub.currency, tag);
        final body = e.kind == ReminderKind.renewal ? s.notifRenewalBody(amount, day) : s.notifOtherBody(day);
        final details = NotificationDetails(
          android: AndroidNotificationDetails(_channelId, s.notifChannel, channelDescription: s.notifChannelHelp,
            importance: Importance.defaultImportance, priority: Priority.defaultPriority, color: _accent,
            category: AndroidNotificationCategory.reminder, groupKey: 'app.ritmia.reminders', subText: amount,
            styleInformation: BigTextStyleInformation(body, contentTitle: title, summaryText: 'Ritmia')),
          iOS: const DarwinNotificationDetails(threadIdentifier: 'ritmia-reminders'));
        await _plugin.zonedSchedule(id: i + 1, title: title, body: body,
          scheduledDate: tz.TZDateTime(tz.local, d.year, d.month, d.day, 9),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, payload: sub.id);
      }
    });
    _pending = task.catchError((Object _) {});
    return task;
  }
}
