import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compile-time product switches.
///
/// Ritmia Pro (one-time unlock, upsell sheet and the house "go Pro" interstitial)
/// is fully implemented but hidden in this release. Re-enable it with
/// `--dart-define=RITMIA_PRO_ENABLED=true`; real purchases additionally need
/// `RITMIA_BILLING_ENABLED=true` and the server-owned billing grant.
/// The Free quota (five subscriptions) is enforced regardless of this switch.
abstract final class Features {
  static const pro = bool.fromEnvironment('RITMIA_PRO_ENABLED');
}

/// Whether Pro upsell surfaces are visible. Overridable in tests.
final proFeatureProvider = Provider<bool>((_) => Features.pro);
