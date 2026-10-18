import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
class LocalRepository implements SubscriptionRepository {
  LocalRepository(this.preferences);
  final SharedPreferences preferences;
  final _changes=StreamController<List<Subscription>>.broadcast();
  final _entitlements=StreamController<Entitlement>.broadcast();
  Future<void> _pending=Future.value();
  static const _key='ritmia.local.subscriptions.v1';
  static const _proKey='ritmia.local.pro.v1';
  // Local mode allows unlimited subscriptions without paywalls.
  bool get _pro => true;
  List<Subscription> _read()=>(jsonDecode(preferences.getString(_key)??'[]') as List)
    .map((e)=>Subscription.fromJson(Map<String,dynamic>.from(e as Map))).toList();
  @override
  Stream<List<Subscription>> watch() async* {yield _read();yield* _changes.stream;}
  @override
  Stream<Entitlement> watchEntitlement() async* {yield Entitlement(pro:_pro);yield* _entitlements.stream;}
  Future<void> setPro(bool value) async {
    await preferences.setBool(_proKey,value);
    if(!_entitlements.isClosed)_entitlements.add(Entitlement(pro:value));
  }
  Future<T> _mutate<T>(T Function(List<Subscription>) change){
    final result=_pending.then((_)async{
      final items=_read();final value=change(items);
      if(!await preferences.setString(_key,jsonEncode(items.map((s)=>s.toJson()).toList())))throw const AppFailure('storage');
      _changes.add(items);return value;
    });
    _pending=result.then<void>((_){}).catchError((Object _){});
    return result;
  }
  @override
  Future<Subscription> save(Subscription s)=>_mutate((items){
    final index=items.indexWhere((i)=>i.id==s.id);
    if(index<0&&!_pro&&items.length>=5)throw const AppFailure('limit');
    final revision=index<0?0:items[index].revision;
    if(s.revision!=revision)throw const AppFailure('conflict');
    final saved=Subscription.fromJson({...s.toJson(),'revision':revision+1});
    if(index<0){items.add(saved);}else{items[index]=saved;}
    return saved;
  });
  @override
  Future<void> delete(Subscription s)=>_mutate<void>((items){
    final index=items.indexWhere((i)=>i.id==s.id);
    if(index<0)return;
    if(items[index].revision!=s.revision)throw const AppFailure('conflict');
    items.removeAt(index);
  });
  @override
  Future<Subscription> setLogo(Subscription s,Uint8List bytes)async{
    if(bytes.length>131072)throw const AppFailure('image');
    return save(s.withLogo(null,bytes:base64Encode(bytes)));
  }
  @override
  Future<Uint8List?> loadLogo(Subscription s)async=>s.localLogo==null?null:base64Decode(s.localLogo!);
  @override
  void dispose(){_changes.close();_entitlements.close();}
}
