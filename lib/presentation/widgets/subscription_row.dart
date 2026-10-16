import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/subscription.dart';
import '../../l10n/context.dart';
import 'service_avatar.dart';

/// Clean list row: mark, name and next date on the left; amount and cadence right-aligned.
class SubscriptionRow extends StatelessWidget {
  const SubscriptionRow({super.key, required this.item, required this.onTap, this.subtitle, this.compactTrailing = false});
  final Subscription item;
  final VoidCallback onTap;
  final String? subtitle;
  /// Calendar variant: single-line amount followed by a chevron.
  final bool compactTrailing;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    final next = item.nextRenewal(DateTime.now());
    final secondary = subtitle ?? switch (item.status) {
      SubscriptionStatus.paused => s.paused,
      SubscriptionStatus.archived => s.archived,
      _ => next == null ? s.noRenewal : context.dayMonth(next),
    };
    final price = item.free ? s.free : context.amountWithCode(item.amountMinor, item.currency);
    const tab = TextStyle(fontFeatures: BrandTheme.tabular);
    return Semantics(button: true, child: InkWell(onTap: onTap, child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 76),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
        ServiceAvatar(item: item),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: t.textPrimary)),
          const SizedBox(height: 3),
          Text(secondary, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, color: t.textSecondary)),
        ])),
        const SizedBox(width: 12),
        if (compactTrailing) ...[
          Text(price, style: tab.copyWith(fontSize: 16, color: t.textPrimary)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: t.textSecondary),
        ] else Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: tab.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
          if (!item.free) ...[
            const SizedBox(height: 3),
            Text(context.perCycle(item.cycle), style: TextStyle(fontSize: 14, color: t.textSecondary)),
          ],
        ]),
      ])))));
  }
}
