import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/environment.dart';
import 'core/onboarding_provider.dart';
import 'presentation/onboarding_screen.dart';
import 'core/providers.dart';
import 'core/reminder_providers.dart';
import 'core/theme.dart';
import 'l10n/context.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/auth_screen.dart';
import 'presentation/home_screen.dart';
class RitmiaApp extends ConsumerWidget {
  const RitmiaApp({super.key,this.startupError});
  final String? startupError;
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return MaterialApp(title:'Ritmia',debugShowCheckedModeBanner:false,theme:BrandTheme.light,darkTheme:BrandTheme.dark,themeMode:ref.watch(themeModeProvider),
      locale:ref.watch(localeProvider),localizationsDelegates:AppLocalizations.localizationsDelegates,
      supportedLocales:AppLocalizations.supportedLocales,
      home:Builder(builder:(context){
        if(startupError!=null)return Scaffold(body:Center(child:Padding(padding:const EdgeInsets.all(32),child:Text(context.l10n.cloudSetupError))));
        ref.watch(reminderSyncProvider);
        final preferences=ref.watch(preferencesProvider);
        if(preferences.isLoading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
        if(preferences.hasError)return Scaffold(body:Center(child:Text(context.l10n.genericError)));
        if(!ref.watch(onboardingProvider))return const OnboardingScreen();
        if(Environment.cloud){
          return ref.watch(authProvider).when(
            data:(user)=>user==null?const AuthScreen():const HomeScreen(),
            loading:()=>const Scaffold(body:Center(child:CircularProgressIndicator())),
            error:(error,stack)=>Scaffold(body:Center(child:Text(context.l10n.genericError))));
        }
        return ref.watch(preferencesProvider).when(
          data:(_)=>const HomeScreen(),
          loading:()=>const Scaffold(body:Center(child:CircularProgressIndicator())),
          error:(error,stack)=>Scaffold(body:Center(child:Text(context.l10n.genericError))));
      }));
  }
}
