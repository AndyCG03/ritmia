import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/subscription.dart';
import '../../l10n/context.dart';
import '../../l10n/currency_names.dart';
import 'sheet.dart';

String currencyName(BuildContext context, String code) {
  final localized=additionalCurrencyNames[Localizations.localeOf(context).languageCode]?[code];
  if(localized!=null)return localized;
  final names = currencyNames[code];
  if (names == null) return code;
  return Localizations.localeOf(context).languageCode == 'es' ? names.$1 : names.$2;
}

/// Searchable currency list ("peso", "MXN", "mex"…). Returns the chosen ISO code.
Future<String?> showCurrencySheet(BuildContext context, String selected) =>
  showRitmiaSheet<String>(context, heightFactor: 0.8, builder: (_) => _CurrencySheet(selected: selected));

class _CurrencySheet extends StatefulWidget {
  const _CurrencySheet({required this.selected});
  final String selected;
  @override
  State<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends State<_CurrencySheet> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    final q = _q.toLowerCase().trim();
    final list = currencies.where((c) => q.isEmpty || c.toLowerCase().contains(q) || currencyName(context, c).toLowerCase().contains(q)).toList();
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(s.chooseCurrency, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary))),
        const SheetCloseButton(),
      ]),
      const SizedBox(height: 12),
      TextField(autofocus: false, onChanged: (v) => setState(() => _q = v),
        decoration: InputDecoration(hintText: s.searchCurrency, prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary))),
      const SizedBox(height: 8),
      Expanded(child: ListView.separated(itemCount: list.length, separatorBuilder: (_, _) => const Hairline(), itemBuilder: (c, i) {
        final code = list[i], on = code == widget.selected;
        return InkWell(onTap: () => Navigator.pop(context, code), child: SizedBox(height: 56, child: Row(children: [
          SizedBox(width: 56, child: Text(code, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary, fontFeatures: BrandTheme.tabular))),
          Expanded(child: Text(currencyName(context, code), style: TextStyle(fontSize: 16, color: t.textPrimary))),
          if (on) Icon(Icons.check_rounded, color: t.textAction),
        ])));
      })),
    ]));
  }
}
