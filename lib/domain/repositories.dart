import 'dart:typed_data';
import 'subscription.dart';

class AppFailure implements Exception {
  const AppFailure(this.code);
  final String code;
  @override
  String toString() => code;
}
class Entitlement {
  const Entitlement({this.pro = false});
  final bool pro;
  bool get showAds => !pro;
  int? get subscriptionLimit => pro ? null : 5;
  bool canCreate(int count) => pro || count < 5;
}
abstract interface class SubscriptionRepository {
  Stream<List<Subscription>> watch();
  Stream<Entitlement> watchEntitlement();
  Future<Subscription> save(Subscription subscription);
  Future<void> delete(Subscription subscription);
  Future<Subscription> setLogo(Subscription subscription, Uint8List bytes);
  Future<Uint8List?> loadLogo(Subscription subscription);
  void dispose();
}
