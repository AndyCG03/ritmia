import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../core/catalog.dart';
import '../core/errors.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key,this.item,this.initialBrand});
  final Subscription? item;
  /// Catalog choice from the add sheet; pre-fills name, color and provider link.
  final ServiceBrand? initialBrand;
  @override
  ConsumerState<EditorScreen> createState()=>_EditorScreenState();
}
class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _form=GlobalKey<FormState>();
  late final TextEditingController _name,_amount,_notes,_url;
  late final String _id;
  late String _currency;
  late DateTime _anchor;
  DateTime? _ends,_trial;
  late bool _free;
  bool _busy=false,_removeLogo=false;
  late int _color;
  String? _brand;
    late BillingCycle _cycle;
  late SubscriptionStatus _status;
  late Category _category;
  late Set<int> _reminders;
  Uint8List? _image;
  @override
  void initState(){
    super.initState(); final s=widget.item;
    _id=s?.id??newId();_name=TextEditingController(text:s?.name??'');
    _currency=s?.currency??'USD';
    _amount=TextEditingController(text:s==null?'':(s.amountMinor/(_currency=='JPY'?1:100)).toStringAsFixed(currencyDigits(_currency)));
    _notes=TextEditingController(text:s?.notes??'');_url=TextEditingController(text:s?.cancelUrl??'');
    _anchor=s==null?dateOnly(DateTime.now()):DateTime.parse(s.anchorDate);
    _ends=s?.endsOn==null?null:DateTime.parse(s!.endsOn!);
    _trial=s?.trialEndsOn==null?null:DateTime.parse(s!.trialEndsOn!);
    _free=s?.free??false;_color=s?.color??BrandTheme.colors.first;_brand=s?.brandId;
    _cycle=s?.cycle??BillingCycle.monthly;_status=s?.status??SubscriptionStatus.active;
    _category=s?.category??Category.other;_reminders=(s?.reminderDays??[3,1]).toSet();
    final b=widget.initialBrand;
    if(s==null&&b!=null){_brand=b.id;_name.text=b.name;_color=b.color;_url.text=b.cancelUrl;
      if(aiBrandIds.contains(b.id))_category=Category.productivity;}
  }
  @override
  void dispose(){for(final c in [_name,_amount,_notes,_url]){c.dispose();}super.dispose();}
  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(context:context,
    initialDate:initial??DateTime.now(),firstDate:DateTime(2000),lastDate:DateTime(2100,12,31));
  Future<void> _pickImage() async {
    try {
      final file=await ImagePicker().pickImage(source:ImageSource.gallery,maxWidth:256,maxHeight:256,imageQuality:85);
      if(file==null)return;
      if(await file.length()>4*1024*1024)throw const AppFailure('image');
      final decoded=img.decodeImage(await file.readAsBytes());
      if(decoded==null||decoded.width*decoded.height>16000000)throw const AppFailure('image');
      final small=img.copyResize(decoded,width:decoded.width>=decoded.height?256:null,height:decoded.height>decoded.width?256:null);
      final bytes=Uint8List.fromList(img.encodePng(small));
      if(bytes.length>131072)throw const AppFailure('image');
      if(mounted)setState((){_image=bytes;_removeLogo=false;});
    }catch(error){if(mounted)showFailure(context,error);}
  }
  Future<void> _save() async {
    if(!_form.currentState!.validate())return;
    if(_ends!=null&&!_ends!.isAfter(_anchor)){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.dateOrder)));return;
    }
    setState(()=>_busy=true);
    var saved=false;
    try {
      final repo=ref.read(repositoryProvider);
      if(repo==null)throw const AppFailure('storage');
      final s=Subscription(id:_id,name:_name.text.trim(),amountMinor:_free?0:parseAmount(_amount.text,_currency)!,
        currency:_currency,free:_free,anchorDate:dateKey(_anchor),cycle:_cycle,color:_color,brandId:_brand,
        status:_status,category:_category,notes:_notes.text.trim(),cancelUrl:_url.text.trim(),
        endsOn:_ends==null?null:dateKey(_ends!),trialEndsOn:_trial==null?null:dateKey(_trial!),
        reminderDays:_reminders.toList()..sort(),revision:widget.item?.revision??0,
        logoPath:_removeLogo?null:widget.item?.logoPath,localLogo:_removeLogo?null:widget.item?.localLogo);
      final savedRecord=await repo.save(s); saved=true;
      if(_image!=null)await repo.setLogo(savedRecord,_image!);
      if(mounted)Navigator.pop(context);
    }catch(error){
      if(mounted){
        if(saved){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(context.l10n.logoPartialError)));Navigator.pop(context);}
        else {showFailure(context,error);}
      }
    }finally{if(mounted)setState(()=>_busy=false);}
  }
  Widget _gap()=>const SizedBox(height:18);
  @override
  Widget build(BuildContext context) {
    final s=context.l10n;
    return Scaffold(appBar:AppBar(title:Text(widget.item==null?s.add:s.edit)),body:Center(
      child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:680),child:Form(key:_form,child:ListView(
        padding:const EdgeInsets.fromLTRB(24,12,24,40),children:[

          TextFormField(controller:_name,maxLength:80,decoration:InputDecoration(labelText:s.name),
            validator:(v)=>v==null||v.trim().isEmpty||v.trim().length>80?s.invalidName:null),
          SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(s.free),value:_free,onChanged:_busy?null:(v)=>setState(()=>_free=v)),
          if(!_free)...[
            TextFormField(controller:_amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:s.amount),
              validator:(v)=>_free?null:(parseAmount(v??'',_currency)??0)<=0?s.invalidAmount:null),_gap(),
          ],
          DropdownButtonFormField<String>(initialValue:_currency,decoration:InputDecoration(labelText:s.currency),
            items:currencies.map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),
            onChanged:_busy?null:(v)=>setState(()=>_currency=v!)),_gap(),
          DropdownButtonFormField<BillingCycle>(initialValue:_cycle,decoration:InputDecoration(labelText:s.billingCycle),
            items:BillingCycle.values.map((c)=>DropdownMenuItem(value:c,child:Text(context.cycleLabel(c)))).toList(),
            onChanged:_busy?null:(v)=>setState(()=>_cycle=v!)),_gap(),
          ListTile(contentPadding:EdgeInsets.zero,title:Text(s.anchorDate),subtitle:Text(context.shortDate(_anchor)),
            trailing:const Icon(Icons.event_outlined),onTap:_busy?null:()async{final date=await _pick(_anchor);if(date!=null&&mounted)setState(()=>_anchor=date);}),
          _gap(),DropdownButtonFormField<Category>(initialValue:_category,decoration:InputDecoration(labelText:s.category),
            items:Category.values.map((c)=>DropdownMenuItem(value:c,child:Text(context.categoryLabel(c)))).toList(),
            onChanged:_busy?null:(v)=>setState(()=>_category=v!)),_gap(),
          DropdownButtonFormField<SubscriptionStatus>(initialValue:_status,decoration:InputDecoration(labelText:s.status),
            items:SubscriptionStatus.values.map((c)=>DropdownMenuItem(value:c,child:Text(context.statusLabel(c)))).toList(),
            onChanged:_busy?null:(v)=>setState(()=>_status=v!)),_gap(),
          Text(s.color,style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:8),
          Wrap(spacing:12,children:BrandTheme.colors.map((c)=>Semantics(label:'${s.color} ${BrandTheme.colors.indexOf(c)+1}',selected:c==_color,
            child:IconButton(style:IconButton.styleFrom(backgroundColor:Color(c),foregroundColor:Colors.white),
              onPressed:_busy?null:()=>setState(()=>_color=c),icon:Icon(c==_color?Icons.check:Icons.circle_outlined)))).toList()),
          _gap(),Text(s.logo,style:Theme.of(context).textTheme.titleMedium),Text(s.logoHelp),
          if(_image!=null)Padding(padding:const EdgeInsets.all(12),child:Image.memory(_image!,height:64)),
          Wrap(spacing:12,children:[
            OutlinedButton.icon(onPressed:_busy?null:_pickImage,icon:const Icon(Icons.add_photo_alternate_outlined),label:Text(s.uploadLogo)),
            if(_image!=null||widget.item?.logoPath!=null||widget.item?.localLogo!=null)
              TextButton(onPressed:_busy?null:()=>setState((){_image=null;_removeLogo=true;}),child:Text(s.removeLogo)),
          ]),
          _gap(),Text(s.reminders,style:Theme.of(context).textTheme.titleMedium),Text(s.reminderHelp),const SizedBox(height:8),
          Wrap(spacing:8,children:[(1,s.daysOne),(3,s.daysThree),(7,s.daysSeven),(14,s.daysFourteen)].map((e)=>FilterChip(
            label:Text(e.$2),selected:_reminders.contains(e.$1),onSelected:_busy?null:(v)=>setState((){v?_reminders.add(e.$1):_reminders.remove(e.$1);}))).toList()),
          for(final kind in ['trial','end'])ListTile(contentPadding:EdgeInsets.zero,
            title:Text(kind=='trial'?s.trialEndsOn:s.endsOn),
            subtitle:Text((kind=='trial'?_trial:_ends)==null?'—':context.shortDate((kind=='trial'?_trial:_ends)!)),
            onTap:_busy?null:()async{final date=await _pick(kind=='trial'?_trial:_ends);if(date!=null&&mounted)setState((){if(kind=='trial'){_trial=date;}else{_ends=date;}});},
            trailing:IconButton(tooltip:s.clear,onPressed:_busy?null:()=>setState((){if(kind=='trial'){_trial=null;}else{_ends=null;}}),icon:const Icon(Icons.close))),
          _gap(),TextFormField(controller:_url,maxLength:500,decoration:InputDecoration(labelText:s.cancelUrl,helperText:s.manageHelp,helperMaxLines:3),
            validator:(v){if(v==null||v.trim().isEmpty)return null;final uri=Uri.tryParse(v.trim());return uri!=null&&uri.scheme=='https'&&uri.host.contains('.')?null:s.invalidUrl;}),
          _gap(),TextFormField(controller:_notes,maxLength:1000,maxLines:3,decoration:InputDecoration(labelText:s.notes)),
          _gap(),FilledButton.icon(onPressed:_busy?null:_save,icon:_busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.check),
            label:Text(_busy?s.loading:s.save)),
        ])))));
  }
}
