import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/catalog.dart';
import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/subscription.dart';
import '../../l10n/context.dart';
import '../editor_screen.dart';
import '../widgets/service_avatar.dart';
import 'sheet.dart';

Future<void> showDetailSheet(BuildContext context, Subscription item) =>
  showRitmiaSheet(context, maxFactor: 0.9, builder: (_) => DetailSheet(id: item.id, fallback: item));

/// Manage one subscription. Pausing or deleting only affects Ritmia's record, never the provider contract.
class DetailSheet extends ConsumerStatefulWidget {
  const DetailSheet({super.key, required this.id, required this.fallback});
  final String id;
  final Subscription fallback;
  @override
  ConsumerState<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends ConsumerState<DetailSheet> {
  bool _busy = false;

  void _edit(Subscription item) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute<void>(builder: (_) => EditorScreen(item: item)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try { await action(); } catch (error) { if (mounted) showFailure(context, error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  /// Don't renew → end the plan on the next renewal (the cancel deadline). Renew again → clear it.
  Future<void> _setRenews(Subscription item, bool renews) async {
    final s = context.l10n;
    if (renews) { await _run(() => ref.read(repositoryProvider)!.save(item.withEndsOn(null))); return; }
    final next = item.nextRenewal(DateTime.now());
    if (next == null) return;
    final ok = await showConfirmSheet(context, icon: Icons.event_busy_outlined, title: s.stopRenewTitle(item.name),
      body: s.stopRenewBody(context.dayMonthYear(next)), confirmLabel: s.stopRenewing);
    if (!ok || !mounted) return;
    await _run(() => ref.read(repositoryProvider)!.save(item.withEndsOn(dateKey(next))));
  }

  Future<void> _delete(Subscription item) async {
    final s = context.l10n;
    final ok = await showConfirmSheet(context, icon: Icons.delete_outline_rounded, destructive: true,
      title: s.deleteTitle, body: s.deleteBody, confirmLabel: s.deleteRecord);
    if (!ok || !mounted) return;
    await _run(() async {
      await ref.read(repositoryProvider)!.delete(item);
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _manage(Subscription item) => _run(() async {
    if (!await launchUrl(Uri.parse(item.cancelUrl), mode: LaunchMode.externalApplication)) throw StateError('url');
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    final items = ref.watch(subscriptionsProvider).asData?.value;
    final item = items?.where((i) => i.id == widget.id).firstOrNull ?? widget.fallback;
    final next = item.nextRenewal(DateTime.now());
    final provider = findBrand(item.brandId)?.name ?? item.name;
    final hasLink = item.cancelUrl.isNotEmpty;
    final label = TextStyle(fontSize: 16, color: t.textSecondary);
    final value = TextStyle(fontSize: 16, color: t.textPrimary, fontFeatures: BrandTheme.tabular);

    Widget row(String l, Widget v, {VoidCallback? onTap}) => Column(children: [
      InkWell(onTap: _busy ? null : onTap, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 56),
        child: Row(children: [Expanded(child: Text(l, style: label)), v]))),
      const Hairline(),
    ]);

    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 12), child: ServiceAvatar(item: item, size: 76)),
          const SizedBox(width: 18),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: t.textPrimary, height: 1.15)),
            const SizedBox(height: 2),
            Text(context.renewalLabel(item.cycle), style: TextStyle(fontSize: 17, color: t.textSecondary)),
            const SizedBox(height: 10),
            if (item.free) Text(s.free, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: t.textPrimary))
            else Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 8, children: [
              Text(context.amount(item.amountMinor, item.currency), style: TextStyle(fontSize: 36, height: 1.1,
                fontWeight: FontWeight.w700, letterSpacing: -1, color: t.textPrimary, fontFeatures: BrandTheme.tabular)),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(item.currency,
                style: TextStyle(fontSize: 19, color: t.textPrimary, fontWeight: FontWeight.w500))),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(context.perCycle(item.cycle),
                style: TextStyle(fontSize: 17, color: t.textSecondary))),
            ]),
          ]))),
          const SheetCloseButton(),
        ]),
        const SizedBox(height: 24),
        if (item.status == SubscriptionStatus.active) ...[
          SizedBox(width: double.infinity, child: SegmentedButton<bool>(showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, icon: const Icon(Icons.autorenew_rounded, size: 18), label: Text(s.willRenew)),
              ButtonSegment(value: false, icon: const Icon(Icons.event_busy_outlined, size: 18), label: Text(s.stopRenewing)),
            ], selected: {!item.stopsRenewing},
            onSelectionChanged: _busy ? null : (v) => _setRenews(item, v.first))),
          const SizedBox(height: 16),
        ],
        const Hairline(),
        if (item.stopsRenewing) row(s.notRenewing, Text(s.cancelBefore(context.dayMonthYear(item.renewalDeadline!)),
          style: value.copyWith(color: t.alert, fontWeight: FontWeight.w600)))
        else row(s.nextRenewal, Text(next == null ? s.noRenewal : context.dayMonthYear(next), style: value)),
        row(s.billingCycle, Text(context.cycleLabel(item.cycle), style: value)),
        row(s.reminders, Row(children: [
          Text(context.remindersSummary(item.reminderDays), style: value),
          const SizedBox(width: 8), Icon(Icons.chevron_right_rounded, color: t.textSecondary),
        ]), onTap: () => _edit(item)),
        const SizedBox(height: 12),
        InkWell(onTap: _busy || !hasLink ? null : () => _manage(item), borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 2, left: 4),
              child: Icon(Icons.open_in_new_rounded, size: 24, color: hasLink ? t.textPrimary : t.textSecondary)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.manage, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: hasLink ? t.textPrimary : t.textSecondary)),
              const SizedBox(height: 2),
              Text(hasLink ? s.providerHelp(provider) : s.noProviderLink, style: TextStyle(fontSize: 15, color: t.textSecondary)),
            ])),
          ]))),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : () => _edit(item), child: Text(s.edit)),
        const SizedBox(height: 12),
        TextButton(onPressed: _busy ? null : () => _delete(item),
          style: TextButton.styleFrom(foregroundColor: t.danger), child: Text(s.deleteRecord)),
        const SizedBox(height: 8),
        Text(s.notCancelHelp, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: t.textSecondary)),
      ]));
  }
}
