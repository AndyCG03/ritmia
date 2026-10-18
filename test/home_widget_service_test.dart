import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/services/home_widget_service.dart';
import 'package:ritmia/services/notification_service.dart';
import 'package:ritmia/domain/subscription.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.ritmia/widget');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch(call.method) { 'getLaunchSubscription' => 'tapped', 'requestPin' => true, _ => null };
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    NotificationService.instance.openedSubscription.value = null;
  });
  test('snapshot excludes inactive records and images and restores the tapped plan', () async {
    final active = Subscription(id:'a',name:'ChatGPT',amountMinor:2000,currency:'USD',free:false,
      anchorDate:'2026-10-31',cycle:BillingCycle.monthly,color:0,endsOn:'2026-11-30',
      localLogo:'large-private-image',notes:'private notes');
    final paused = Subscription.fromJson({...active.toJson(),'id':'p','status':'paused'});
    await HomeWidgetService().sync([active,paused],const Locale('es'), theme:ThemeMode.dark);
    final snapshot=jsonDecode(calls.last.arguments as String) as Map<String,dynamic>;
    expect(snapshot['theme'],'dark'); expect(snapshot['locale'],'');
    final item=(snapshot['items'] as List).single as Map<String,dynamic>;
    expect(item['id'],'a');expect(item['endsOn'],'2026-11-30');expect(item['amount'],'20,00 USD');
    expect(item.containsKey('localLogo'),isFalse);expect(item.containsKey('notes'),isFalse);
    expect(NotificationService.instance.openedSubscription.value,'tapped');
  });
  test('empty snapshot clears the widget and pinning uses the native launcher', () async {
    final service=HomeWidgetService();
    await service.sync([],const Locale('en'),overrideLocale:const Locale('en'));
    expect((jsonDecode(calls.last.arguments as String) as Map)['items'],isEmpty);
    expect(await service.requestPin(),isTrue);
    expect(calls.last.arguments,isNull);
    expect(await service.requestPin(compact: true),isTrue);
    expect(calls.last.arguments,{'compact': true});
  });
}
