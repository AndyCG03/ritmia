import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors.dart';
import '../core/providers.dart';
import '../core/supported_languages.dart';
import '../l10n/context.dart';
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState()=>_AuthScreenState();
}
class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form=GlobalKey<FormState>();
  final _email=TextEditingController(),_password=TextEditingController();
  bool _register=false,_busy=false,_hidden=true;
  @override
  void dispose(){_email.dispose();_password.dispose();super.dispose();}
  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return;
    setState(()=>_busy=true);
    try {
      final auth=FirebaseAuth.instance;
      if(_register) {
        final result=await auth.createUserWithEmailAndPassword(email:_email.text.trim(),password:_password.text);
        await result.user!.sendEmailVerification();
      } else {await auth.signInWithEmailAndPassword(email:_email.text.trim(),password:_password.text);}
    } catch(error){if(mounted) showFailure(context,error);}
    finally {if(mounted) setState(()=>_busy=false);}
  }
  Future<void> _reset() async {
    if(!_email.text.contains('@')) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.invalidEmail)));return; }
    setState(()=>_busy=true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email:_email.text.trim());
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.resetSent)));
    } catch(error) {if(mounted) showFailure(context,error);}
    finally {if(mounted) setState(()=>_busy=false);}
  }
  @override
  Widget build(BuildContext context){
    final s=context.l10n;
    return Scaffold(appBar:AppBar(actions:[
      PopupMenuButton<String>(tooltip:s.language,icon:const Icon(Icons.translate_rounded),
        onSelected:(code)=>ref.read(localeProvider.notifier).setLocale(Locale(code)),
        itemBuilder:(_)=>[for(final e in languageNames.entries) PopupMenuItem(value:e.key,child:Text(e.value))]),
    ]),body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:SingleChildScrollView(
      padding:const EdgeInsets.all(28),child:Form(key:_form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Center(child:ClipRRect(borderRadius:BorderRadius.circular(24),child:Image.asset('assets/brand/app-icon-ai.png',width:90,height:90))),
        const SizedBox(height:20),Text('Ritmia',textAlign:TextAlign.center,style:Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight:FontWeight.w800)),
        Text(s.tagline,textAlign:TextAlign.center),const SizedBox(height:36),
        TextFormField(controller:_email,keyboardType:TextInputType.emailAddress,autofillHints:const [AutofillHints.email],
          decoration:InputDecoration(labelText:s.email),validator:(v)=>v!=null&&RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())?null:s.invalidEmail),
        const SizedBox(height:16),TextFormField(controller:_password,obscureText:_hidden,autofillHints:[_register?AutofillHints.newPassword:AutofillHints.password],
          decoration:InputDecoration(labelText:s.password,helperText:_register?s.passwordHelp:null,
            suffixIcon:IconButton(onPressed:()=>setState(()=>_hidden=!_hidden),tooltip:s.password,icon:Icon(_hidden?Icons.visibility_outlined:Icons.visibility_off_outlined))),
          validator:(v)=>v!=null&&v.length>=(_register?8:1)?null:s.weakPassword,onFieldSubmitted:(_)=>_busy?null:_submit()),
        const SizedBox(height:24),FilledButton(onPressed:_busy?null:_submit,child:Text(_busy?s.loading:_register?s.signUp:s.signIn)),
        TextButton(onPressed:_busy?null:()=>setState(()=>_register=!_register),child:Text(_register?s.signIn:s.signUp)),
        TextButton(onPressed:_busy?null:_reset,child:Text(s.forgotPassword)),
        const SizedBox(height:24),Text(s.privacy,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall),
      ]))))));
  }
}
