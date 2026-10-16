import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:share_plus/share_plus.dart';
import '../core/environment.dart';
import '../core/errors.dart';
import '../core/providers.dart';
import '../core/reminder_providers.dart';
import '../core/theme.dart';
import '../domain/export.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
import '../services/notification_service.dart';
import 'sheets/permission_sheet.dart';
final emailPreferencesProvider=StreamProvider<Map<String,dynamic>>((ref){
  final user=ref.watch(authProvider).asData?.value;
  if(!Environment.cloud||user==null)return Stream.value({});
  return FirebaseFirestore.instance.doc('users/${user.uid}/private/preferences').snapshots().map((d)=>d.data()??{});
});
class SettingsScreen extends ConsumerStatefulWidget{
  const SettingsScreen({super.key,required this.items,required this.plan});
  final List<Subscription> items;
  final Entitlement plan;
  @override
  ConsumerState<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends ConsumerState<SettingsScreen>{
  bool _busy=false;
  Future<void> _action(Future<void> Function() action)async{
    setState(()=>_busy=true);
    try{await action();}catch(error){if(mounted)showFailure(context,error);}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _email(bool enabled)async{
    final zone=await FlutterTimezone.getLocalTimezone();
    if(!mounted)return;
    final locale=Localizations.localeOf(context).languageCode;
    await FirebaseFunctions.instanceFor(region:'us-central1').httpsCallable('setReminderPreferences')
      .call({'emailEnabled':enabled,'timeZone':zone.identifier,'locale':locale});
  }
  Future<void> _export()async{
    final box=context.findRenderObject() as RenderBox?;
    final origin=box==null?null:box.localToGlobal(Offset.zero)&box.size;
    final bytes=Uint8List.fromList(utf8.encode(exportCsv(widget.items)));
    await SharePlus.instance.share(ShareParams(
      files:[XFile.fromData(bytes,mimeType:'text/csv',name:'ritmia.csv')],
      fileNameOverrides:['ritmia.csv'],sharePositionOrigin:origin));
  }
  @override
  Widget build(BuildContext context){
    final s=context.l10n,user=ref.watch(authProvider).asData?.value;
    final emailState=ref.watch(emailPreferencesProvider);
    final emailEnabled=emailState.asData?.value['emailEnabled']==true;
    final sync=ref.watch(reminderSyncProvider);
    return ListView(padding:const EdgeInsets.fromLTRB(24,16,24,40),children:[
      Text(s.settings,style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:24),Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(widget.plan.pro?s.proPlan:s.freePlan,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),
        const SizedBox(height:12),Text(widget.plan.pro?s.proFeatures:s.freeFeatures),
        if(!widget.plan.pro)...[const SizedBox(height:12),Text('${widget.items.length} / 5',style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text(s.quotaHelp)],
        const Divider(height:32),Text(s.proPlan,style:const TextStyle(fontWeight:FontWeight.w700)),Text(s.proFeatures),
        const SizedBox(height:12),Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:context.tokens.field,borderRadius:BorderRadius.circular(12)),child:Text(s.proPending)),
      ]))),
      const SizedBox(height:24),DropdownButtonFormField<String>(initialValue:ref.watch(localeProvider)?.languageCode??'system',
        decoration:InputDecoration(labelText:s.language),items:[
          DropdownMenuItem(value:'system',child:Text(s.system)),const DropdownMenuItem(value:'es',child:Text('Español')),
          const DropdownMenuItem(value:'en',child:Text('English')),
        ],onChanged:_busy?null:(v)=>_action(()async{
          await ref.read(localeProvider.notifier).setLocale(v=='system'?null:Locale(v!));
          if(emailEnabled&&mounted)await _email(true);
        })),
      const SizedBox(height:16),DropdownButtonFormField<ThemeMode>(initialValue:ref.watch(themeModeProvider),
        decoration:InputDecoration(labelText:s.theme),items:[
          DropdownMenuItem(value:ThemeMode.system,child:Text(s.system)),
          DropdownMenuItem(value:ThemeMode.light,child:Text(s.themeLight)),
          DropdownMenuItem(value:ThemeMode.dark,child:Text(s.themeDark)),
        ],onChanged:(v)=>ref.read(themeModeProvider.notifier).set(v!)),
      const SizedBox(height:24),Text(s.reminders,style:Theme.of(context).textTheme.titleLarge),
      if(NotificationService.instance.supported)SwitchListTile(contentPadding:EdgeInsets.zero,
        title:Text(s.notificationToggle),subtitle:Text(s.notificationHelp),value:ref.watch(deviceAlertsProvider),
        onChanged:_busy?null:(enabled)=>_action(()async{
          if(enabled){await askForReminders(context,ref);}
          else {await ref.read(deviceAlertsProvider.notifier).setEnabled(false);}
        })),
      if(ref.watch(systemBlockedProvider).asData?.value==true)ListTile(contentPadding:EdgeInsets.zero,
        leading:Icon(Icons.notifications_off_outlined,color:context.tokens.danger),title:Text(s.permBlockedBanner),
        onTap:()=>showBlockedSheet(context)),
      if(kIsWeb)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Text(s.webNotificationHelp)),
      if(sync.hasError)ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.warning_amber),
        title:Text(s.notificationError),trailing:IconButton(tooltip:s.retry,onPressed:()=>ref.invalidate(reminderSyncProvider),icon:const Icon(Icons.refresh))),
      if(Environment.cloud)SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(s.emailToggle),
        subtitle:Text(s.emailHelp),value:emailEnabled,onChanged:_busy||emailState.isLoading?null:(v)=>_action(()=>_email(v))),
      const SizedBox(height:24),Card(child:ListTile(contentPadding:const EdgeInsets.all(20),
        leading:const Icon(Icons.file_download_outlined),title:Text(s.export),subtitle:Text(s.exportHelp),
        onTap:_busy?null:()=>_action(_export))),
      if(user!=null)...[
        const SizedBox(height:24),Text(s.account,style:Theme.of(context).textTheme.titleLarge),
        ListTile(contentPadding:EdgeInsets.zero,title:Text(user.email??''),subtitle:Text(user.emailVerified?s.verified:s.emailHelp),
          trailing:Icon(user.emailVerified?Icons.verified_outlined:Icons.email_outlined)),
        if(!user.emailVerified)OutlinedButton(onPressed:_busy?null:()=>_action(()async{
          await user.sendEmailVerification();
          if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s.verificationSent)));
        }),child:Text(s.verifyEmail)),
        TextButton(onPressed:_busy?null:()=>_action(()async{
          await NotificationService.instance.sync([],false,const Locale('en'));
          await FirebaseAuth.instance.signOut();
        }),child:Text(s.signOut)),
      ],
      const SizedBox(height:32),Text(s.privacy,style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:8),const Text('Ritmia · 1.0.0',style:TextStyle(fontSize:12)),
    ]);
  }
}
