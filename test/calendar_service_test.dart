import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/domain/subscription.dart';
void main(){
  testWidgets('calendar action opens a cancellation draft on the correct civil date',(tester)async{
    final now=dateOnly(DateTime.now()),date=dateOnly(DateTime.now()).add(const Duration(days:3));
    final item=Subscription(id:'calendar-plan',name:'Plan calendar',amountMinor:1299,currency:'USD',free:false,
      anchorDate:dateKey(now),purchasedOn:dateKey(now),cycle:BillingCycle.monthly,color:0,endsOn:dateKey(date));
    SharedPreferences.setMockInitialValues({'onboardingComplete':true,'locale':'en','ritmia.local.subscriptions.v1':jsonEncode([item.toJson()])});
    MethodCall? received;const channel=MethodChannel('app.ritmia/calendar');
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel,(call)async{received=call;return true;});
    addTearDown(()=>messenger.setMockMethodCallHandler(channel,null));
    await tester.pumpWidget(ProviderScope(overrides:[reminderSyncProvider.overrideWith((_)async{})],child:const RitmiaApp()));await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Plan calendar'));await tester.tap(find.text('Plan calendar'));await tester.pumpAndSettle();
    final action=find.widgetWithText(OutlinedButton,'Add to device calendar');
    await tester.ensureVisible(action);await tester.pumpAndSettle();await tester.tap(action);await tester.pumpAndSettle();
    expect(received?.method,'insertEvent');
    final args=received!.arguments as Map;
    expect(args['title'],'Cancel Plan calendar');
    expect(args['begin'],DateTime.utc(date.year,date.month,date.day).millisecondsSinceEpoch);
    expect(args['end'],DateTime.utc(date.year,date.month,date.day+1).millisecondsSinceEpoch);
    expect(tester.takeException(),isNull);
  });
}
