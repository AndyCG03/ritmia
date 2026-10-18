import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
class FirebaseSubscriptionRepository implements SubscriptionRepository {
  FirebaseSubscriptionRepository(this.uid);
  final String uid;
  final _db=FirebaseFirestore.instance;
  final _functions=FirebaseFunctions.instanceFor(region:'us-central1');
  @override
  Stream<List<Subscription>> watch()=>_db.collection('users/$uid/subscriptions').snapshots()
    .map((e)=>e.docs.map((d)=>Subscription.fromJson(d.data())).toList());
  @override
  Stream<Entitlement> watchEntitlement()=>_db.doc('users/$uid/private/billing').snapshots().map((doc){
    final data=doc.data(),expires=data?['expiresAt'];
    final active=data?['lifetime']==true||(expires is Timestamp&&expires.toDate().isAfter(DateTime.now()));
    return Entitlement(pro:data?['plan']=='pro'&&active);
  });
  @override
  Future<Subscription> save(Subscription s)async{
    final json=s.toJson()..remove('localLogo');
    final result=await _functions.httpsCallable('saveSubscription').call<Map<String,dynamic>>(json);
    return Subscription.fromJson(Map<String,dynamic>.from(result.data));
  }
  @override
  Future<void> delete(Subscription s)async{
    await _functions.httpsCallable('deleteSubscription').call({'id':s.id,'revision':s.revision});
  }
  @override
  Future<Subscription> setLogo(Subscription s,Uint8List bytes)async{
    if(bytes.length>131072)throw const AppFailure('image');
    final path='users/$uid/logos/${s.id}/${s.revision}.png';
    await FirebaseStorage.instance.ref(path).putData(bytes,SettableMetadata(contentType:'image/png'));
    return save(s.withLogo(path));
  }
  @override
  Future<Uint8List?> loadLogo(Subscription s)=>s.logoPath==null?Future.value(null)
    :FirebaseStorage.instance.ref(s.logoPath!).getData(131072);
  @override
  void dispose(){}
}
