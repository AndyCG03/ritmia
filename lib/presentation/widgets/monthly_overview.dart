import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';

/// Currency totals remain separate. Compact header + two-column cards keep the home screen balanced.
class MonthlyOverview extends StatelessWidget {
  const MonthlyOverview({super.key, required this.totals, required this.count});
  final Map<String, int> totals;
  final int count;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    return LayoutBuilder(builder: (context, constraints) {
      final entries = totals.entries.toList();
      final columns = entries.length > 1 && constraints.maxWidth >= 280 &&
          MediaQuery.textScalerOf(context).scale(16) <= 21 ? 2 : 1;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.thisMonth.toUpperCase(), style: TextStyle(fontSize: 12, letterSpacing: 1.4,
            fontWeight: FontWeight.w600, color: t.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: t.tile, borderRadius: BorderRadius.circular(99),
              border: Border.all(color: t.separator.withValues(alpha: 0.6))),
            child: Text(s.subscriptionCount(count), style: TextStyle(fontSize: 12.5,
              fontWeight: FontWeight.w500, fontFeatures: BrandTheme.tabular, color: t.textSecondary)),
          ),
        ]),
        const SizedBox(height: 10),
        if (entries.isEmpty) Text(s.noCharges, style: TextStyle(fontSize: 26,
          fontWeight: FontWeight.w600, color: t.textPrimary))
        else if (entries.length == 1)
          Semantics(label: context.amountWithCode(entries.first.value, entries.first.key),
            child: ExcludeSemantics(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(context.amount(entries.first.value, entries.first.key),
                  style: TextStyle(fontSize: 38, height: 1.08, fontWeight: FontWeight.w700,
                    letterSpacing: -1.4, fontFeatures: BrandTheme.tabular, color: t.textPrimary)),
                const SizedBox(width: 8),
                Text(entries.first.key, style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w600, letterSpacing: 0.6, color: t.textAction)),
              ]))))
        else for (var start = 0; start < entries.length; start += columns) ...[
          if (start > 0) const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var col = 0; col < columns; col++) ...[
              if (col > 0) const SizedBox(width: 10),
              Expanded(child: start + col >= entries.length ? const SizedBox.shrink() :
                Semantics(label: context.amountWithCode(entries[start+col].value, entries[start+col].key),
                  child: ExcludeSemantics(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(color: t.field, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.separator.withValues(alpha: 0.65))),
                    child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text(context.amount(entries[start+col].value, entries[start+col].key),
                          style: TextStyle(fontSize: 27, height: 1.1, fontWeight: FontWeight.w700,
                            letterSpacing: -0.9, fontFeatures: BrandTheme.tabular, color: t.textPrimary)),
                        const SizedBox(width: 6),
                        Text(entries[start+col].key, style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600, letterSpacing: 0.5, color: t.textAction)),
                      ])))))),
            ],
          ]),
        ],
      ]);
    });
  }
}
