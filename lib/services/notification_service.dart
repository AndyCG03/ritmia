import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

abstract interface class NotificationPermissionGateway {
  bool get supported;
  Future<PermissionOutcome> requestPermission();
  Future<bool> enabledInSystem();
}

class NotificationService implements NotificationPermissionGateway {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  Future<void> _pending = Future.value();

  /// Subscription id from a tapped reminder; the home screen opens its detail sheet.
  final openedSubscription = ValueNotifier<String?>(null);

  static const _channelId = 'ritmia_renewals_v2';
  static const _accent = Color(0xFF7251AF);

  @override
  bool get supported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> initialize() => _initializing ??= _initialize().catchError((Object error, StackTrace stack) {
    _initializing = null; // A transient platform failure must remain retryable.
    Error.throwWithStackTrace(error, stack);
  });

  Future<void> _initialize() async {
    if (!supported) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_ritmia'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false)),
      onDidReceiveNotificationResponse: (r) => openedSubscription.value = r.payload);
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) openedSubscription.value = launch!.notificationResponse?.payload;
  }

  static const _settings = MethodChannel('app.ritmia/settings');

  /// Opens the phone's notification settings for Ritmia (Android). Returns false when unavailable.
  Future<bool> openSystemSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try { return await _settings.invokeMethod<bool>('openNotificationSettings') ?? false; }
    on PlatformException { return false; } on MissingPluginException { return false; }
  }

  /// Whether the OS currently lets Ritmia post notifications (Android 13+ can revoke it from Settings).
  @override
  Future<bool> enabledInSystem() async {
    if (!supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Permission checks must not depend on notification icons or scheduling setup.
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
    }
    await initialize();
    final perms = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions();
    return perms?.isEnabled ?? false;
  }

  @override
  Future<PermissionOutcome> requestPermission() async {
    if (!supported) return PermissionOutcome.unsupported;
    if (defaultTargetPlatform != TargetPlatform.android) await initialize();
    if (await enabledInSystem()) return PermissionOutcome.granted;
    final bool ok;
    if (defaultTargetPlatform == TargetPlatform.android) {
      ok = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    } else {
      ok = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return (ok || await enabledInSystem()) ? PermissionOutcome.granted : PermissionOutcome.denied;
  }

  Future<void> sendTest(Locale locale) async {
    if (!await enabledInSystem()) throw PlatformException(code: 'notifications-denied');
    await initialize();
    final s = await AppLocalizations.delegate.load(locale);
    await _plugin.show(id: 900001, title: s.notifTestTitle, body: s.notifTestBody,
      notificationDetails: NotificationDetails(android: AndroidNotificationDetails(
        _channelId, s.notifChannel, channelDescription: s.notifChannelHelp,
        importance: Importance.high, priority: Priority.high, color: _accent,
        visibility: NotificationVisibility.private,
        styleInformation: BigTextStyleInformation(s.notifTestBody)),
        iOS: const DarwinNotificationDetails()));
  }

  String _money(int minor, String currency, String tag) => '${NumberFormat.decimalPatternDigits(locale: tag,
    decimalDigits: currencyDigits(currency)).format(minor / (currencyDigits(currency) == 0 ? 1 : 100))} $currency';

  Future<void> sync(List<Subscription> items, bool enabled, Locale locale) {
    final task = _pending.then((_) async {
      if (!supported) return;
      await initialize();
      if (!enabled || !await enabledInSystem()) {
        await _plugin.cancelAllPendingNotifications();
        return;
      }
      // Timezone setup belongs only to scheduling, never to permission activation.
      tzdata.initializeTimeZones();
      try {
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
      } catch (_) {
        // Android supplies a second IANA source if the timezone plugin fails.
        final identifier = await _settings.invokeMethod<String>('getTimeZone');
        if (identifier == null) rethrow;
        tz.setLocalLocation(tz.getLocation(identifier));
      }
      await _plugin.cancelAllPendingNotifications();
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
          ReminderKind.ending => s.notifCancelTitle(sub.name, when),
        };
        final day = DateFormat.MMMMEEEEd(tag).format(e.target);
        final amount = sub.free ? s.free : _money(sub.amountMinor, sub.currency, tag);
        final body = e.kind == ReminderKind.ending && !sub.free ? s.notifCancelBody(amount, day)
          : e.kind == ReminderKind.renewal ? s.notifRenewalBody(amount, day) : s.notifOtherBody(day);
        final details = NotificationDetails(
          android: AndroidNotificationDetails(_channelId, s.notifChannel, channelDescription: s.notifChannelHelp,
            importance: Importance.high, priority: Priority.high,
            color: e.kind == ReminderKind.ending ? const Color(0xFFF47D68) : _accent,
            visibility: NotificationVisibility.private,
            category: AndroidNotificationCategory.reminder, subText: 'Ritmia · $amount',
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
