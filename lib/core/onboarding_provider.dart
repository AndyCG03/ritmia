import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
class OnboardingController extends Notifier<bool>{
  @override
  bool build()=>ref.watch(preferencesProvider).asData?.value.getBool('onboardingComplete')??false;
  Future<void> complete()async{
    final prefs=await ref.read(preferencesProvider.future);
    await prefs.setBool('onboardingComplete',true);state=true;
  }
}
final onboardingProvider=NotifierProvider<OnboardingController,bool>(OnboardingController.new);
