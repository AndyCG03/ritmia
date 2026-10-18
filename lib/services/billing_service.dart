import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_repository.dart';
import '../domain/repositories.dart';

/// One-time lifetime unlock gateway for Ritmia Pro.
class BillingService {
  const BillingService({this.enabled = _defaultEnabled});
  static const productId = 'ritmia_pro_lifetime';
  static const _defaultEnabled = bool.fromEnvironment('RITMIA_BILLING_ENABLED');
  static const _channel = MethodChannel('app.ritmia.ritmia/billing');

  final bool enabled;

  Future<bool> purchaseLifetime(SubscriptionRepository? repository) async {
    if (!enabled) return false;
    try {
      final granted = await _channel.invokeMethod<bool>(
        'purchaseLifetime',
        {'productId': productId},
      );
      if (granted == true && repository is LocalRepository) {
        await repository.setPro(true);
      }
      return granted == true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> restorePurchase(SubscriptionRepository? repository) async {
    if (!enabled) return false;
    try {
      final restored = await _channel.invokeMethod<bool>(
        'restorePurchase',
        {'productId': productId},
      );
      if (restored == true && repository is LocalRepository) {
        await repository.setPro(true);
      }
      return restored == true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final billingServiceProvider = Provider<BillingService>(
  (_) => const BillingService(),
);
