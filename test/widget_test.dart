import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/catalog.dart';
import 'package:ritmia/core/reminder_providers.dart';
void main(){
  setUp((){SharedPreferences.setMockInitialValues({'locale':'en','onboardingComplete':true});});
  Future<void> open(WidgetTester tester)async{
    await tester.pumpWidget(ProviderScope(overrides:[reminderSyncProvider.overrideWith((ref)async{})],child:const RitmiaApp()));await tester.pumpAndSettle();
  }
  test('catalog contains at least 100 unique local brands',(){
    expect(serviceBrands.length,greaterThanOrEqualTo(100));
    expect(serviceBrands.map((b)=>b.id).toSet().length,serviceBrands.length);
  });
  test('AI catalog and aliases',(){
    expect(searchBrands('',aiOnly:true).first.name,'ChatGPT');
    expect(searchBrands('gpt').map((b)=>b.id),contains('openai'));
    expect(searchBrands('anthropic').map((b)=>b.id),contains('claude'));
    expect(searchBrands('copilot').map((b)=>b.id),contains('microsoftcopilot'));
    for(final id in ['openai','claude','googlegemini','perplexity','microsoftcopilot','midjourney','cursor','elevenlabs','poe']){
      expect(aiBrandIds,contains(id));
    }
  });
  testWidgets('single home screen opens calendar and settings sheets', (tester)async{
    await open(tester);expect(find.text('Make room for what matters.'),findsOneWidget);
    expect(find.byType(NavigationBar),findsNothing);
    await tester.tap(find.byTooltip('Open calendar').last);await tester.pumpAndSettle();
    expect(find.text('Today'),findsOneWidget);
    expect(find.text('Tap a date to see its renewals'),findsOneWidget);
    await tester.tap(find.byTooltip('Close').last);await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));await tester.pumpAndSettle();
    expect(find.text('Ritmia Free'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('catalog sheet, AI tab and creation of a free subscription', (tester)async{
    await open(tester);await tester.tap(find.text('Add subscription').last);await tester.pumpAndSettle();
    expect(find.text('Artificial intelligence'),findsOneWidget);
    expect(find.text('ChatGPT'),findsOneWidget);
    await tester.tap(find.text('All'));await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField),'Vercel');await tester.pumpAndSettle();
    await tester.tap(find.text('Vercel').last);await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Free'),300,scrollable:find.byType(Scrollable).last);
    await tester.tap(find.text('Free'));await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Save'),500,scrollable:find.byType(Scrollable).last);
    await tester.tap(find.text('Save'));await tester.pumpAndSettle();
    expect(find.text('Vercel'),findsOneWidget);
    await tester.tap(find.text('Vercel'));await tester.pumpAndSettle();
    expect(find.text('Delete record'),findsOneWidget);
    expect(find.text('This does not cancel your plan with the provider.'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
