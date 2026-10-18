import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repositories.dart';

/// Manages occasional interstitial ad frequency for the Free tier.
/// When Ritmia Pro is active (`plan.pro == true`), all ads are disabled.
class AdService {
  const AdService({this.frequency = 3});

  /// Official Google AdMob test interstitial unit ID for Android; override in production via dart-define.
  static const interstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const _saveCountKey = 'ritmia.ads.saveCount.v1';

  final int frequency;

  Future<bool> recordSaveAndShouldShowInterstitial(
    SharedPreferences preferences, {
    required Entitlement plan,
    required bool inTour,
  }) async {
    if (!plan.showAds || inTour || frequency <= 0) return false;
    final next = (preferences.getInt(_saveCountKey) ?? 0) + 1;
    await preferences.setInt(_saveCountKey, next);
    return next % frequency == 0;
  }
}

final adServiceProvider = Provider<AdService>((_) => const AdService());
