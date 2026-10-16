import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ritmia/core/reminder_providers.dart';
import 'package:ritmia/app.dart';
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
  test('three Lottie assets parse as real compositions',()async{
    for(final file in ['rhythm','calendar','bell']){
      final composition=await AssetLottie('assets/lottie/$file.json').load();
      expect(composition.duration.inSeconds,4);expect(composition.layers,isNotEmpty);
    }
  });
}
