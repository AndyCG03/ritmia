import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/subscription.dart';
import '../core/supported_languages.dart';
import '../l10n/generated/app_localizations.dart';
import 'notification_service.dart';

/// Native RemoteViews read a small private snapshot, never credentials or uploaded images.
class HomeWidgetService {
  static const _channel = MethodChannel('app.ritmia/widget');
  String _money(Subscription i,String locale) => '${NumberFormat.decimalPatternDigits(locale:locale,decimalDigits:currencyDigits(i.currency)).format(i.amountMinor / (currencyDigits(i.currency)==0?1:100))} ${i.currency}';
  bool _initialized = false;
  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Future<void> sync(List<Subscription> items, Locale locale, {Locale? overrideLocale, ThemeMode theme = ThemeMode.system}) async {
    if (!supported) return;
    try {
      if (!_initialized) {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'openSubscription') {
            NotificationService.instance.openedSubscription.value = call.arguments as String?;
          }
        });
        final id = await _channel.invokeMethod<String>('getLaunchSubscription');
        if (id != null) NotificationService.instance.openedSubscription.value = id;
        _initialized = true;
      }
      final s = await AppLocalizations.delegate.load(supportedLocale(locale));
      await _channel.invokeMethod<void>('sync', jsonEncode({
        'locale': overrideLocale?.languageCode ?? '', 'theme': theme.name,
        'items': [for (final i in items.where((i) => i.status == SubscriptionStatus.active)) {
          'id': i.id, 'name': i.name, 'free': i.free, 'anchorDate': i.anchorDate, 'cycle': i.cycle.name,
          'endsOn': i.endsOn, 'purchasedOn': i.purchasedOn,
          'amount': i.free ? s.free : _money(i,s.localeName),
        }],
      }));
    } on MissingPluginException { /* Unsupported test/desktop host. */ }
  }
  /// True means the launcher accepted the request, not that the user confirmed placement.
  Future<bool> requestPin({bool compact = false}) async {
    if (!supported) return false;
    try { return await _channel.invokeMethod<bool>('requestPin', compact ? {'compact': true} : null) ?? false; }
    on MissingPluginException { return false; }
  }
}
