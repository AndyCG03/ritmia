import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/catalog.dart';
import 'package:ritmia/core/features.dart';
import 'package:ritmia/domain/repositories.dart';
import 'package:ritmia/domain/subscription.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/services/ad_service.dart';
void main(){
  setUp((){SharedPreferences.setMockInitialValues({'locale':'en','onboardingComplete':true});});
  Future<void> open(WidgetTester tester)async{
    await tester.pumpWidget(ProviderScope(overrides:[reminderSyncProvider.overrideWith((ref)async{})],child:const RitmiaApp()));await tester.pumpAndSettle();
  }
  test('catalog contains at least 100 unique local brands',(){
    expect(serviceBrands.length,greaterThanOrEqualTo(100));
    expect(serviceBrands.map((b)=>b.id).toSet().length,serviceBrands.length);
  });
  test('retired brands and currencies are available',(){
    for(final id in ['linkedin','slack','canva','primevideo','microsoftteams','xbox']){expect(findBrand(id),isNotNull,reason:id);}
    expect(searchBrands('linked').first.id,'linkedin');
    expect(currencies,containsAll(['MXN','ARS','COP','CLP','BRL']));
    expect(currencyDigits('CLP'),0);expect(currencyNames["MXN"]!.$1,'Peso mexicano');
  });
  test('free service that becomes paid only charges from its start day',(){
    final s=Subscription(id:'x',name:'Trial',amountMinor:19900,currency:'MXN',free:false,anchorDate:'2026-11-05',
      trialEndsOn:'2026-11-05',cycle:BillingCycle.monthly,color:0);
    expect(chargesInMonth([s],DateTime(2026,10)),isEmpty);
    expect(chargesInMonth([s],DateTime(2026,11)),{'MXN':19900});
  });
  test('purchase date is stored and falls back to the anchor',(){
    final s=Subscription(id:'p',name:'P',amountMinor:100,currency:'USD',free:false,anchorDate:'2026-11-05',cycle:BillingCycle.monthly,color:0,purchasedOn:'2026-10-05');
    expect(Subscription.fromJson(s.toJson()).purchasedOn,'2026-10-05');
    expect(Subscription.fromJson({...s.toJson()}..remove('purchasedOn')).purchaseDate,DateTime(2026,11,5));
  });
  test('AI catalog and aliases',(){
    expect(searchBrands('',aiOnly:true).first.name,'ChatGPT');
    expect(searchBrands('gpt').map((b)=>b.id),contains('openai'));
    expect(searchBrands('higssfield',aiOnly:true).single.id,'higgsfield');
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
    expect(find.text('Unlimited subscriptions'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('catalog sheet, AI tab and creation of a free subscription', (tester)async{
    await open(tester);await tester.tap(find.text('Add subscription').last);await tester.pumpAndSettle();
    expect(find.text('Artificial intelligence'),findsOneWidget);
    expect(searchBrands('').any((b) => !b.ai),isTrue);
    await tester.tap(find.text('Artificial intelligence'));await tester.pumpAndSettle();
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
  testWidgets("don't renew marks the cancel deadline and stops renewals", (tester)async{
    final now=DateTime.now();
    final anchor=dateKey(DateTime(now.year,now.month,now.day).add(const Duration(days:3)));
    final sub={'id':'s1','name':'Netflix','amountMinor':1500,'currency':'USD','free':false,'anchorDate':anchor,'cycle':'monthly',
      'color':0xFF282338,'brandId':'netflix','status':'active','category':'entertainment','notes':'','logoPath':null,'revision':1,
      'reminderDays':[1],'endsOn':null,'trialEndsOn':null,'cancelUrl':''};
    SharedPreferences.setMockInitialValues({'locale':'en','onboardingComplete':true,'ritmia.local.subscriptions.v1':jsonEncode([sub])});
    await open(tester);
    await tester.tap(find.text('Netflix'));await tester.pumpAndSettle();
    expect(find.text('Renews'),findsOneWidget);
    await tester.tap(find.text("Don't renew"));await tester.pumpAndSettle();
    expect(find.text('Stop renewing Netflix?'),findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton,"Don't renew"));await tester.pumpAndSettle();
    expect(find.text("Won't renew"),findsOneWidget);
    expect(find.textContaining('Cancel before'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('add custom service button matches add subscription height and size with gesture inset', (tester)async{
    tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
    tester.view.padding=const FakeViewPadding(top:44,bottom:34);
    tester.view.viewPadding=const FakeViewPadding(top:44,bottom:34);
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);addTearDown(tester.view.resetViewPadding);
    await open(tester);
    final addButton=find.widgetWithText(FilledButton,'Add subscription');
    final addRect=tester.getRect(addButton);
    expect(addRect.height,56);
    await tester.tap(addButton);await tester.pumpAndSettle();
    final customButton=find.widgetWithText(FilledButton,'Add custom service');
    final customRect=tester.getRect(customButton);
    expect(customRect,addRect);
  });
  testWidgets('changing purchase date or cycle automatically updates paidFrom date', (tester)async{
    await open(tester);
    await tester.tap(find.text('Add subscription').last);await tester.pumpAndSettle();
    await tester.tap(find.text('Artificial intelligence'));await tester.pumpAndSettle();
    await tester.tap(find.text('ChatGPT').last);await tester.pumpAndSettle();
    await tester.tap(find.text('Free'));await tester.pumpAndSettle();
    await tester.tap(find.text('Becomes paid later'));await tester.pumpAndSettle();
    final amountField=find.byWidgetPredicate((w)=>w is TextField&&w.decoration?.labelText=='Amount after that');
    await tester.enterText(amountField,'15');await tester.pumpAndSettle();
    final listScroll=find.descendant(of:find.byType(ListView),matching:find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('Yesterday'),150,scrollable:listScroll);
    await tester.tap(find.text('Yesterday'));await tester.pumpAndSettle();
    final yesterday=dateOnly(DateTime.now()).subtract(const Duration(days:1));
    final expectedMonthly=addBillingCycle(yesterday,BillingCycle.monthly);
    await tester.scrollUntilVisible(find.text('Save'),300,scrollable:listScroll);
    await tester.tap(find.text('Save'));await tester.pumpAndSettle();
    final prefs=await SharedPreferences.getInstance();
    final saved=(jsonDecode(prefs.getString('ritmia.local.subscriptions.v1')!) as List).single as Map<String,dynamic>;
    expect(saved['purchasedOn'],dateKey(yesterday));
    expect(saved['trialEndsOn'],dateKey(expectedMonthly));
    expect(saved['anchorDate'],dateKey(expectedMonthly));
  });
  test('occasional interstitial triggers every 3rd save in Free tier and never in Pro', ()async{
    final prefs=await SharedPreferences.getInstance();
    const ads=AdService(frequency:3);
    expect(await ads.recordSaveAndShouldShowInterstitial(prefs,plan:const Entitlement(),inTour:false),isFalse);
    expect(await ads.recordSaveAndShouldShowInterstitial(prefs,plan:const Entitlement(),inTour:false),isFalse);
    expect(await ads.recordSaveAndShouldShowInterstitial(prefs,plan:const Entitlement(),inTour:false),isTrue);
    expect(await ads.recordSaveAndShouldShowInterstitial(prefs,plan:const Entitlement(pro:true),inTour:false),isFalse);
  });
  testWidgets('settings shows unlimited subscriptions and no paywalls', (tester)async{
    await open(tester);
    await tester.tap(find.byTooltip('Settings'));await tester.pumpAndSettle();
    expect(find.text('Unlimited subscriptions'),findsOneWidget);
    expect(find.text('ONE-TIME PURCHASE · FOREVER'),findsNothing);
    expect(find.textContaining('Ritmia Pro'),findsNothing);
  });
}
