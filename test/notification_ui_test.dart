import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/services/notification_service.dart';
class Permission implements NotificationPermissionGateway {
  bool allowed=false;int requests=0;
  @override bool get supported=>true;
  @override Future<bool> enabledInSystem() async=>allowed;
  @override Future<PermissionOutcome> requestPermission() async{requests++;allowed=true;return PermissionOutcome.granted;}
}
void main(){
  testWidgets('accepting permission leaves the visible switch on',(tester)async{
    SharedPreferences.setMockInitialValues({'onboardingComplete':true,'locale':'en'});
    final permission=Permission();
    await tester.pumpWidget(ProviderScope(overrides:[notificationPermissionProvider.overrideWithValue(permission),
      reminderSyncProvider.overrideWith((_)async{})],child:const RitmiaApp()));await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Switch),200,scrollable:find.byType(Scrollable).last);
    await tester.ensureVisible(find.byType(Switch).first);await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value,isTrue);
    expect(permission.requests,1);
    expect(find.text('Send a test alert'),findsNothing);
    expect(tester.takeException(),isNull);
  });
}
