import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/app.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/core/supported_languages.dart';
import 'package:ritmia/l10n/generated/app_localizations.dart';
void main(){
  test('all four locales have complete translations and preserve placeholders',() async {
    final base=jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String,dynamic>;
    final keys=base.keys.where((k)=>!k.startsWith('@')).toSet();
    for(final code in languageNames.keys){
      final arb=jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String,dynamic>;
      expect(arb.keys.where((k)=>!k.startsWith('@')).toSet(),keys,reason:code);
      for(final key in keys){
        final placeholders=(base['@$key'] as Map?)?['placeholders'] as Map?;
        for(final name in placeholders?.keys??[]){expect(arb[key] as String,contains('{$name'),reason:'$code.$key');}
      }
      final s=await AppLocalizations.delegate.load(Locale(code));
      expect(s.tourProgress(2,11),contains('2'));
      expect(s.subscriptionCount(2),contains('2'));
      expect(s.subscriptionCount(0),contains('0'));
      expect(s.subscriptionCount(1),contains('1'));
    }
    expect(supportedLocale(const Locale('pt','BR')),const Locale('pt'));
    expect(supportedLocale(const Locale('ja')),const Locale('en'));
  });
  for(final (code,title) in [('pt','Abra espaço para o que importa.'),('fr',"Faites place à l'essentiel.")]){
    testWidgets('phone locale $code is selected without onboarding language picker',(tester)async{
      SharedPreferences.setMockInitialValues({'onboardingComplete':true});
      tester.platformDispatcher.localesTestValue=[Locale(code)];addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(ProviderScope(overrides:[reminderSyncProvider.overrideWith((_)async{})],child:const RitmiaApp()));await tester.pumpAndSettle();
      expect(find.text(title),findsOneWidget);
      expect(tester.takeException(),isNull);
    });
  }
}
