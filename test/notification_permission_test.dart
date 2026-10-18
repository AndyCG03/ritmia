import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/core/providers.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/services/notification_service.dart';

class FakePermission implements NotificationPermissionGateway {
  bool granted = false;
  PermissionOutcome outcome = PermissionOutcome.granted;
  int requests = 0;
  @override bool get supported => true;
  @override Future<bool> enabledInSystem() async => granted;
  @override Future<PermissionOutcome> requestPermission() async {
    requests++; granted = outcome == PermissionOutcome.granted; return outcome;
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late FakePermission permission;
  setUp(() async {
    SharedPreferences.setMockInitialValues({}); permission = FakePermission();
    container = ProviderContainer(overrides: [notificationPermissionProvider.overrideWithValue(permission)]);
    await container.read(preferencesProvider.future);
  });
  tearDown(() => container.dispose());
  test('accepting the OS prompt activates and persists immediately', () async {
    final result = await container.read(deviceAlertsProvider.notifier).setEnabled(true);
    expect(result, PermissionOutcome.granted);
    expect(container.read(deviceAlertsProvider), isTrue);
    expect((await container.read(preferencesProvider.future)).getBool('deviceAlerts'), isTrue);
    expect(await container.read(systemBlockedProvider.future), isFalse);
    expect(permission.requests, 1);
  });
  test('denial stays off; returning from system settings completes the request', () async {
    permission.outcome = PermissionOutcome.denied;
    await container.read(deviceAlertsProvider.notifier).setEnabled(true);
    expect(container.read(deviceAlertsProvider), isFalse);
    permission.granted = true;
    await container.read(deviceAlertsProvider.notifier).reconcile();
    expect(container.read(deviceAlertsProvider), isTrue);
  });
  test('explicitly turning off is respected after resume', () async {
    await container.read(deviceAlertsProvider.notifier).setEnabled(true);
    await container.read(deviceAlertsProvider.notifier).setEnabled(false);
    await container.read(deviceAlertsProvider.notifier).reconcile();
    expect(container.read(deviceAlertsProvider), isFalse);
  });
  test('real permission request does not depend on timezone initialization', () async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    const notifications = MethodChannel('dexterous.com/flutter/local_notifications');
    const timezone = MethodChannel('flutter_timezone');
    final calls = <String>[];
    var allowed = false;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(timezone, (_) async => throw PlatformException(code: 'timezone-unavailable'));
    messenger.setMockMethodCallHandler(notifications, (call) async {
      calls.add(call.method);
      return switch(call.method) {
        'initialize' => throw PlatformException(code: 'invalid_icon'),
        'getNotificationAppLaunchDetails' => {'notificationLaunchedApp': false},
        'areNotificationsEnabled' => allowed,
        'requestNotificationsPermission' => allowed = true,
        _ => null,
      };
    });
    try {
      expect(await NotificationService.instance.requestPermission(), PermissionOutcome.granted);
      expect(calls, contains('requestNotificationsPermission'));
      expect(calls, isNot(contains('initialize')), reason: 'A broken posting resource must not block OS permission');
    } finally {
      messenger.setMockMethodCallHandler(notifications, null);
      messenger.setMockMethodCallHandler(timezone, null);
    }
  });
  test('test alert retries failed initialization and does not require a timezone', () async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    const channel=MethodChannel('dexterous.com/flutter/local_notifications');
    var starts=0,shown=0;
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel,(call) async {
      switch(call.method) {
        case 'areNotificationsEnabled':return true;
        case 'initialize':
          starts++;
          if(starts==1)throw PlatformException(code:'invalid_icon');
          return true;
        case 'getNotificationAppLaunchDetails':return {'notificationLaunchedApp':false};
        case 'show':shown++;return null;
        default:return null;
      }
    });
    try {
      await expectLater(NotificationService.instance.sendTest(const Locale('en')),throwsA(isA<PlatformException>()));
      await NotificationService.instance.sendTest(const Locale('en'));
      expect(starts,2);expect(shown,1);
    } finally {messenger.setMockMethodCallHandler(channel,null);}
  });

}
