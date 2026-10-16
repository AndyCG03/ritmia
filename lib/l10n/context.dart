import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'generated/app_localizations.dart';
import '../domain/subscription.dart';
extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String money(int minor, String currency) => NumberFormat.currency(
    locale: Localizations.localeOf(this).toLanguageTag(), name:currency,
    symbol:'$currency ', decimalDigits:currencyDigits(currency)).format(minor / (currencyDigits(currency) == 0 ? 1 : 100));
  String get _tag => Localizations.localeOf(this).toLanguageTag();
  bool get _es => Localizations.localeOf(this).languageCode == 'es';
  /// Number only, e.g. "20,00"; pair with the ISO code shown after it.
  String amount(int minor, String currency) => NumberFormat.decimalPatternDigits(
    locale: _tag, decimalDigits: currencyDigits(currency)).format(minor / (currencyDigits(currency) == 0 ? 1 : 100));
  /// "20,00 USD" — the reading order used across Ritmia rows.
  String amountWithCode(int minor, String currency) => '${amount(minor, currency)} $currency';
  String perCycle(BillingCycle cycle) => switch(cycle) {
    BillingCycle.weekly => l10n.perWeek, BillingCycle.monthly => l10n.perMonth,
    BillingCycle.quarterly => l10n.perQuarter, BillingCycle.yearly => l10n.perYear,
  };
  String _cap(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
  /// "20 oct"
  String dayMonth(DateTime d) => DateFormat('d MMM', _tag).format(d).replaceAll('.', '');
  /// "20 oct 2026"
  String dayMonthYear(DateTime d) => DateFormat('d MMM y', _tag).format(d).replaceAll('.', '');
  /// "Octubre"
  String monthName(DateTime d) => _cap(DateFormat.MMMM(_tag).format(d));
  /// "Octubre 2026"
  String monthYear(DateTime d) => _cap(DateFormat('MMMM y', _tag).format(d));
  /// "Martes, 20 de octubre"
  String longDay(DateTime d) => _cap(_es ? DateFormat("EEEE, d 'de' MMMM", _tag).format(d) : DateFormat.MMMMEEEEd(_tag).format(d));
  /// Narrow weekday initial, Monday first: L M X J V S D.
  String weekdayInitial(int mondayIndex) => _es
    ? const ['L','M','X','J','V','S','D'][mondayIndex]
    : DateFormat.EEEEE(_tag).format(DateTime(2024, 1, 1 + mondayIndex));
  String renewalLabel(BillingCycle cycle) => l10n.renewalLabel(_es ? cycleLabel(cycle).toLowerCase() : cycleLabel(cycle));
  String remindersSummary(List<int> days) {
    if (days.isEmpty) return l10n.noReminders;
    final sorted = [...days]..sort((a, b) => b.compareTo(a));
    // "3 días y 1 día antes": keep the unit on every value for clarity.
    final full = sorted.map(l10n.daysBefore).toList();
    final list = full.length == 1 ? full.first : '${full.sublist(0, full.length - 1).join(', ')} ${l10n.and} ${full.last}';
    return l10n.remindersBefore(list);
  }
  String shortDate(DateTime date) => DateFormat.yMMMd(Localizations.localeOf(this).toLanguageTag()).format(date);
  String cycleLabel(BillingCycle cycle) => switch(cycle) {
    BillingCycle.weekly => l10n.weekly, BillingCycle.monthly => l10n.monthly,
    BillingCycle.quarterly => l10n.quarterly, BillingCycle.yearly => l10n.yearly,
  };
  String statusLabel(SubscriptionStatus status) => switch(status) {
    SubscriptionStatus.active => l10n.active, SubscriptionStatus.paused => l10n.paused,
    SubscriptionStatus.archived => l10n.archived,
  };
  String categoryLabel(Category category) => switch(category) {
    Category.entertainment => l10n.entertainment, Category.productivity => l10n.productivity,
    Category.storage => l10n.storageCategory, Category.education => l10n.education,
    Category.health => l10n.health, Category.utilities => l10n.utilities, Category.other => l10n.other,
  };
}
