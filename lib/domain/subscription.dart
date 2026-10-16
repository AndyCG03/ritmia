import 'dart:convert';
import 'dart:math';
enum BillingCycle { weekly, monthly, quarterly, yearly }
enum SubscriptionStatus { active, paused, archived }
enum Category { entertainment, productivity, storage, education, health, utilities, other }
/// ISO 4217 codes Ritmia accepts. Keep in sync with functions/src/domain.ts.
const currencies = ['USD', 'EUR', 'MXN', 'ARS', 'COP', 'CLP', 'PEN', 'UYU', 'BOB', 'PYG', 'VES', 'BRL', 'DOP', 'CUP', 'GTQ', 'HNL', 'NIO', 'CRC', 'PAB', 'CAD', 'GBP', 'CHF', 'AUD', 'NZD', 'JPY', 'CNY', 'KRW', 'INR', 'SEK', 'NOK', 'DKK', 'PLN', 'TRY'];
const zeroDecimalCurrencies = {'JPY', 'CLP', 'PYG', 'KRW'};
/// Display names (es, en) for the currency picker.
const currencyNames = <String, (String, String)>{
  'USD': ('Dólar estadounidense', 'US dollar'),
  'EUR': ('Euro', 'Euro'),
  'MXN': ('Peso mexicano', 'Mexican peso'),
  'ARS': ('Peso argentino', 'Argentine peso'),
  'COP': ('Peso colombiano', 'Colombian peso'),
  'CLP': ('Peso chileno', 'Chilean peso'),
  'PEN': ('Sol peruano', 'Peruvian sol'),
  'UYU': ('Peso uruguayo', 'Uruguayan peso'),
  'BOB': ('Boliviano', 'Bolivian boliviano'),
  'PYG': ('Guaraní paraguayo', 'Paraguayan guaraní'),
  'VES': ('Bolívar venezolano', 'Venezuelan bolívar'),
  'BRL': ('Real brasileño', 'Brazilian real'),
  'DOP': ('Peso dominicano', 'Dominican peso'),
  'CUP': ('Peso cubano', 'Cuban peso'),
  'GTQ': ('Quetzal guatemalteco', 'Guatemalan quetzal'),
  'HNL': ('Lempira hondureño', 'Honduran lempira'),
  'NIO': ('Córdoba nicaragüense', 'Nicaraguan córdoba'),
  'CRC': ('Colón costarricense', 'Costa Rican colón'),
  'PAB': ('Balboa panameño', 'Panamanian balboa'),
  'CAD': ('Dólar canadiense', 'Canadian dollar'),
  'GBP': ('Libra esterlina', 'Pound sterling'),
  'CHF': ('Franco suizo', 'Swiss franc'),
  'AUD': ('Dólar australiano', 'Australian dollar'),
  'NZD': ('Dólar neozelandés', 'New Zealand dollar'),
  'JPY': ('Yen japonés', 'Japanese yen'),
  'CNY': ('Yuan chino', 'Chinese yuan'),
  'KRW': ('Won surcoreano', 'South Korean won'),
  'INR': ('Rupia india', 'Indian rupee'),
  'SEK': ('Corona sueca', 'Swedish krona'),
  'NOK': ('Corona noruega', 'Norwegian krone'),
  'DKK': ('Corona danesa', 'Danish krone'),
  'PLN': ('Esloti polaco', 'Polish złoty'),
  'TRY': ('Lira turca', 'Turkish lira'),
};
int currencyDigits(String currency) => zeroDecimalCurrencies.contains(currency) ? 0 : 2;
int? parseAmount(String value, String currency) {
  final text = value.trim().replaceAll(',', '.');
  if (!RegExp(currencyDigits(currency) == 0 ? r'^\d{1,9}$' : r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) return null;
  final parts = text.split('.');
  return int.parse(parts.first) * (currencyDigits(currency) == 0 ? 1 : 100) +
    (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
}
String dateKey(DateTime v) => '${v.year.toString().padLeft(4, '0')}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
DateTime dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);
String newId() { final random = Random.secure(); return base64UrlEncode(List.generate(15, (_) => random.nextInt(256))); }
class Subscription {
  const Subscription({required this.id, required this.name, required this.amountMinor,
    required this.currency, required this.free, required this.anchorDate,
    required this.cycle, required this.color, this.brandId,
    this.status = SubscriptionStatus.active, this.category = Category.other,
    this.notes = '', this.logoPath, this.localLogo, this.revision = 0,
    this.reminderDays = const [3, 1], this.endsOn, this.trialEndsOn, this.cancelUrl = '', this.purchasedOn});
  final String id, name, currency, anchorDate, notes, cancelUrl;
  final String? brandId, logoPath, localLogo, endsOn, trialEndsOn;
  /// Civil date of the first purchase (YYYY-MM-DD); shown in blue on the calendar.
  final String? purchasedOn;
  final int amountMinor, color, revision;
  final List<int> reminderDays;
  final bool free;
  final BillingCycle cycle;
  final SubscriptionStatus status;
  final Category category;
  DateTime occurrence(int index) {
    final anchor = DateTime.parse(anchorDate);
    if (cycle == BillingCycle.weekly) return DateTime(anchor.year, anchor.month, anchor.day + index * 7);
    final step = switch (cycle) {
      BillingCycle.monthly => 1, BillingCycle.quarterly => 3,
      BillingCycle.yearly => 12, BillingCycle.weekly => 0,
    };
    final first = DateTime(anchor.year, anchor.month + step * index, 1);
    return DateTime(first.year, first.month, min(anchor.day, DateTime(first.year, first.month + 1, 0).day));
  }
  Iterable<DateTime> occurrences(DateTime from, DateTime until) sync* {
    if (status != SubscriptionStatus.active) return;
    final start = dateOnly(from), anchor = DateTime.parse(anchorDate);
    final end = endsOn == null ? null : DateTime.parse(endsOn!);
    final months = (start.year - anchor.year) * 12 + start.month - anchor.month;
    var index = max(0, switch (cycle) {
      BillingCycle.weekly => start.difference(anchor).inDays ~/ 7 - 2,
      BillingCycle.monthly => months - 1, BillingCycle.quarterly => months ~/ 3 - 1,
      BillingCycle.yearly => months ~/ 12 - 1,
    });
    while (true) {
      final date = occurrence(index++);
      if (!date.isBefore(until) || (end != null && !date.isBefore(end))) return;
      if (!date.isBefore(start)) yield date;
    }
  }
  /// Renewals: charges after the purchase day. Buying today means the next renewal is one cycle later.
  Iterable<DateTime> renewals(DateTime from, DateTime until) {
    if (purchasedOn == null) return occurrences(from, until); // legacy: anchor was the first renewal
    final bought = DateTime.parse(purchasedOn!);
    return occurrences(from, until).where((d) => d.isAfter(bought));
  }
  DateTime? nextRenewal(DateTime now) => renewals(dateOnly(now), DateTime(now.year + 2, now.month, now.day)).firstOrNull;
  Subscription withLogo(String? path, {String? bytes}) => Subscription(
    id: id, name: name, amountMinor: amountMinor, currency: currency, free: free,
    anchorDate: anchorDate, cycle: cycle, color: color, brandId: brandId, category: category,
    status: status, notes: notes, logoPath: path, localLogo: bytes, revision: revision,
    reminderDays: reminderDays, endsOn: endsOn, trialEndsOn: trialEndsOn, cancelUrl: cancelUrl, purchasedOn: purchasedOn);
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'amountMinor': amountMinor, 'currency': currency,
    'free': free, 'anchorDate': anchorDate, 'cycle': cycle.name, 'color': color,
    'brandId': brandId, 'status': status.name, 'category': category.name, 'notes': notes,
    'logoPath': logoPath, 'revision': revision, 'reminderDays': reminderDays,
    'endsOn': endsOn, 'trialEndsOn': trialEndsOn, 'cancelUrl': cancelUrl,
    if (purchasedOn != null) 'purchasedOn': purchasedOn,
    if (localLogo != null) 'localLogo': localLogo,
  };
  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
    id: j['id'] as String, name: j['name'] as String,
    amountMinor: (j['amountMinor'] as num).toInt(), currency: j['currency'] as String,
    free: j['free'] as bool, anchorDate: j['anchorDate'] as String,
    cycle: BillingCycle.values.byName(j['cycle'] as String), color: (j['color'] as num).toInt(),
    brandId: j['brandId'] as String?, status: SubscriptionStatus.values.byName(j['status'] as String),
    category: Category.values.byName(j['category'] as String? ?? 'other'),
    notes: j['notes'] as String? ?? '', logoPath: j['logoPath'] as String?,
    localLogo: j['localLogo'] as String?, revision: (j['revision'] as num?)?.toInt() ?? 0,
    reminderDays: (j['reminderDays'] as List? ?? [3,1]).map((v) => (v as num).toInt()).toList(),
    endsOn: j['endsOn'] as String?, trialEndsOn: j['trialEndsOn'] as String?, cancelUrl: j['cancelUrl'] as String? ?? '',
    purchasedOn: j['purchasedOn'] as String?);
}
Map<String, int> chargesInMonth(List<Subscription> items, DateTime month) {
  final totals = <String, int>{};
  for (final item in items.where((s) => !s.free)) {
    final count = item.occurrences(DateTime(month.year, month.month), DateTime(month.year, month.month + 1)).length;
    if (count > 0) {
      totals.update(item.currency, (v) => v + item.amountMinor * count,
        ifAbsent: () => item.amountMinor * count);
    }
  }
  return totals;
}
/// "Don't renew": the plan ends on [endsOn], which is also the deadline to cancel with the provider.
extension RenewalChoice on Subscription {
  bool get stopsRenewing => endsOn != null && status == SubscriptionStatus.active;
  DateTime? get renewalDeadline => endsOn == null ? null : DateTime.parse(endsOn!);
  Subscription withEndsOn(String? date) => Subscription.fromJson({...toJson(), 'endsOn': date});
}
extension PurchaseDate on Subscription {
  /// Explicit purchase date, falling back to the anchor for records created before it existed.
  DateTime get purchaseDate => DateTime.parse(purchasedOn ?? anchorDate);
}
