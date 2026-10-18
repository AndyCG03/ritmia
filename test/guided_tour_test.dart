import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/guided_tour_provider.dart';
import 'package:ritmia/core/providers.dart';
import 'package:ritmia/core/reminder_providers.dart';

void main() {
  setUpAll(() async {
    if(!const bool.fromEnvironment('CAPTURE_TOUR'))return;
    const fonts='C:/Users/andyc/flutter_windows_3.29.3-stable/flutter/bin/cache/artifacts/material_fonts';
    for(final (family,file) in [('Roboto','Roboto-Regular.ttf'),('MaterialIcons','MaterialIcons-Regular.otf')]) {
      final loader=FontLoader(family)..addFont(Future.value(ByteData.sublistView(File('$fonts/$file').readAsBytesSync())));
      await loader.load();
    }
    final labels=FontLoader('Ahem');
    for(final file in ['Roboto-Medium.ttf','Roboto-Bold.ttf']) {
      labels.addFont(Future.value(ByteData.sublistView(File('$fonts/$file').readAsBytesSync())));
    }
    await labels.load();
  });
  testWidgets('guided creation uses real form and persists one subscription', (tester) async {
    tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'locale':'en','onboardingComplete':true});
    final container=ProviderContainer(overrides:[reminderSyncProvider.overrideWith((_) async {})]);
    addTearDown(container.dispose);
    final captureKey=GlobalKey();
    Future<void> capture(String name) async {
      if(!const bool.fromEnvironment('CAPTURE_TOUR'))return;
      final previousShadows=debugDisableShadows;
      debugDisableShadows=false;
      final box=captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      box.markNeedsPaint();await tester.pumpAndSettle();
      await tester.runAsync(() async {
      final image=await box.toImage(pixelRatio:2);
      final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
      final dir=Directory('.local/tour-preview')..createSync(recursive:true);
      File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
      });
      debugDisableShadows=previousShadows;
      box.markNeedsPaint();await tester.pumpAndSettle();
    }
    await tester.pumpWidget(RepaintBoundary(key:captureKey,child:UncontrolledProviderScope(container:container,child:const RitmiaApp())));
    await tester.pumpAndSettle();
    container.read(guidedTourProvider.notifier).start();
    await tester.pumpAndSettle();
    expect(find.text('Your first subscription'),findsOneWidget);
    await capture('01-first-subscription');
    await tester.tap(find.text('Add subscription').last);await tester.pumpAndSettle();
    expect(find.text('Choose a brand'),findsOneWidget);
    await tester.enterText(find.byType(TextField),'ChatGPT');await tester.pumpAndSettle();
    await tester.tap(find.text('ChatGPT').last);await tester.pumpAndSettle();
    expect(find.text('Give it a name'),findsOneWidget);
    Future<void> next() async {await tester.tap(find.widgetWithText(FilledButton,'Continue'));await tester.pumpAndSettle();}
    await next();
    await capture('02-price');
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton,'Continue')).onPressed,isNull);
    final amount=find.byWidgetPredicate((w)=>w is TextField&&w.decoration?.labelText=='Amount per cycle');
    await tester.enterText(amount,'12.50');
    FocusManager.instance.primaryFocus?.unfocus();await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton,'Continue')).onPressed,isNotNull);
    await next();expect(find.text('When did you buy it?'),findsOneWidget);
    await next();expect(find.text('Choose your reminders'),findsOneWidget);
    await next();expect(find.text('Save your subscription'),findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton,'Save'));await tester.pumpAndSettle();
    expect(find.text('Here’s your plan'),findsOneWidget);
    await capture('03-saved-plan');
    expect(container.read(subscriptionsProvider).requireValue.single.name,'ChatGPT');
    await next();expect(find.text('See your dates'),findsOneWidget);
    await capture('04-calendar');
    await tester.tap(find.byTooltip('Open calendar').last);await tester.pumpAndSettle();
    expect(container.read(guidedTourProvider).paused,isTrue);
    await tester.tap(find.byTooltip('Close').last);await tester.pumpAndSettle();
    expect(container.read(guidedTourProvider).step,TourStep.filter);
    await next();expect(find.text('Make it yours'),findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton,'Finish'));await tester.pumpAndSettle();
    expect(container.read(guidedTourProvider).step,isNull);
    expect((await container.read(preferencesProvider.future)).getBool('guidedTourComplete'),isTrue);
    expect(container.read(subscriptionsProvider).requireValue.length,1);
    expect(tester.takeException(),isNull);
  });
  testWidgets('skipping the tour creates no sample records', (tester) async {
    SharedPreferences.setMockInitialValues({'locale':'en','onboardingComplete':true});
    final container=ProviderContainer(overrides:[reminderSyncProvider.overrideWith((_) async {})]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container:container,child:const RitmiaApp()));await tester.pumpAndSettle();
    container.read(guidedTourProvider.notifier).start();await tester.pumpAndSettle();
    await tester.tap(find.text('Skip tour').first);await tester.pumpAndSettle();
    expect(container.read(subscriptionsProvider).requireValue,isEmpty);
    expect(container.read(guidedTourProvider).step,isNull);
  });
}
