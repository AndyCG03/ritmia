import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/core/guided_tour_provider.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/services/notification_service.dart';
import 'package:ritmia/app.dart';

class _GrantedGateway implements NotificationPermissionGateway {
  @override
  bool get supported => true;
  @override
  Future<PermissionOutcome> requestPermission() async => PermissionOutcome.granted;
  @override
  Future<bool> enabledInSystem() async => true;
}

void main(){
  testWidgets('onboarding shows Lottie, advances, skips and persists completion',(tester)async{
    SharedPreferences.setMockInitialValues({'locale':'en'});
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue=const FakeAccessibilityFeatures(disableAnimations:true);
    addTearDown(tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(ProviderScope(overrides:[reminderSyncProvider.overrideWith((ref)async{})],child:const RitmiaApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Everything recurring'),findsOneWidget);
    expect(find.byType(Lottie),findsWidgets);
    await tester.tap(find.text('Next'));await tester.pumpAndSettle();
    expect(find.textContaining('No more surprise'),findsOneWidget);
    await tester.tap(find.text('Skip'));await tester.pumpAndSettle();
    expect(find.text('Make room for what matters.'),findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('onboardingComplete'),true);
    expect(tester.takeException(),isNull);
  });
  testWidgets('enabling reminders in onboarding does not show a snackbar over the tutorial',(tester)async{
    tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'locale':'es'});
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue=const FakeAccessibilityFeatures(disableAnimations:true);
    addTearDown(tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final captureKey=GlobalKey();
    Future<void> capture(String name) async {
      if(!const bool.fromEnvironment('CAPTURE_ONBOARDING'))return;
      final box=captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image=await box.toImage(pixelRatio:2);
        final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
        final dir=Directory('.local/onboarding-preview')..createSync(recursive:true);
        File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    final container=ProviderContainer(overrides:[
      reminderSyncProvider.overrideWith((ref)async{}),
      notificationPermissionProvider.overrideWithValue(_GrantedGateway()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(RepaintBoundary(key:captureKey,child:UncontrolledProviderScope(container:container,child:const RitmiaApp())));
    await tester.pumpAndSettle();
    await capture('slide-1-rhythm');
    await tester.tap(find.text('Siguiente'));await tester.pumpAndSettle();
    await capture('slide-2-calendar');
    await tester.tap(find.text('Siguiente'));await tester.pumpAndSettle();
    await capture('slide-3-bell');
    await tester.tap(find.widgetWithText(FilledButton,'Activar avisos'));
    await tester.pumpAndSettle();
    expect(container.read(deviceAlertsProvider),isTrue);
    expect(container.read(guidedTourProvider).step,TourStep.add);
    expect(find.byType(SnackBar),findsNothing);
  });
  test('three Lottie assets parse as real compositions',()async{
    for(final file in ['rhythm','calendar','bell']){
      final composition=await AssetLottie('assets/lottie/$file.json').load();
      expect(composition.duration.inSeconds,4);expect(composition.layers,isNotEmpty);
    }
  });
}
