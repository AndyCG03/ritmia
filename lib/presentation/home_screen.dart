import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/errors.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';
import 'sheets/calendar_sheet.dart';
import 'sheets/catalog_sheet.dart';
import 'sheets/detail_sheet.dart';
import 'sheets/sheet.dart';
import 'widgets/subscription_row.dart';

/// The single main screen. Calendar, detail, catalog, filters and settings open as bottom sheets.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '', _filter = 'all';
  bool _searching = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.openedSubscription.addListener(_openFromNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFromNotification());
  }

  /// A tapped reminder opens that subscription's detail sheet.
  void _openFromNotification() {
    final id = NotificationService.instance.openedSubscription.value;
    if (id == null || !mounted) return;
    final item = ref.read(subscriptionsProvider).asData?.value.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    NotificationService.instance.openedSubscription.value = null;
    showDetailSheet(context, item);
  }

  @override
  void dispose() {
    NotificationService.instance.openedSubscription.removeListener(_openFromNotification);
    _search.dispose(); super.dispose();
  }

  void _add(int count, Entitlement plan) {
    if (!plan.canCreate(count)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.limitMessage)));
      return;
    }
    showCatalogSheet(context);
  }

  void _openSettings(List<Subscription> items, Entitlement plan) => showRitmiaSheet(context, heightFactor: 0.88, maxFactor: 0.9,
    builder: (_) => Column(children: [
      const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 12), child: SheetCloseButton())),
      Expanded(child: SettingsScreen(items: items, plan: plan)),
    ]));

  void _openFilter() {
    final s = context.l10n;
    showRitmiaSheet<void>(context, builder: (c) {
      final t = c.tokens;
      return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: Text(s.filter, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary))), const SheetCloseButton()]),
        const SizedBox(height: 8),
        for (final e in [('all', s.all), ('active', s.active), ('paid', s.paid), ('free', s.free)]) ...[
          InkWell(onTap: () { setState(() => _filter = e.$1); Navigator.pop(c); }, child: SizedBox(height: 56, child: Row(children: [
            Expanded(child: Text(e.$2, style: TextStyle(fontSize: 17, color: t.textPrimary))),
            if (_filter == e.$1) Icon(Icons.check_rounded, color: t.textAction),
          ]))),
          const Hairline(),
        ],
      ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n, t = context.tokens;
    final data = ref.watch(subscriptionsProvider);
    ref.listen(subscriptionsProvider, (_, _) => _openFromNotification());
    final plan = ref.watch(entitlementProvider).asData?.value ?? const Entitlement();
    final items = data.asData?.value ?? const <Subscription>[];
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent, systemNavigationBarColor: t.background),
      child: Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: Column(children: [
        Expanded(child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(errorMessage(context, error), textAlign: TextAlign.center),
            TextButton(onPressed: () => ref.invalidate(subscriptionsProvider), child: Text(s.retry)),
          ])),
          data: (_) => _content(items, plan))),
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: data.asData == null ? null : () => _add(items.length, plan),
          icon: const Icon(Icons.add_rounded, size: 28), label: Text(s.add)))),
      ]))))));
  }

  Widget _content(List<Subscription> all, Entitlement plan) {
    final s = context.l10n, t = context.tokens;
    final now = DateTime.now(), today = dateOnly(now);
    final totals = chargesInMonth(all, now);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final week = renewalsBetween(all, monday, monday.add(const Duration(days: 7)));
    final q = _query.toLowerCase();
    final visible = all.where((i) => '${i.name} ${i.notes}'.toLowerCase().contains(q) && switch (_filter) {
      'free' => i.free, 'paid' => !i.free, 'active' => i.status == SubscriptionStatus.active, _ => true,
    }).toList()..sort((a, b) => (a.nextRenewal(now) ?? DateTime(9999)).compareTo(b.nextRenewal(now) ?? DateTime(9999)));
    final iconColor = t.textPrimary;

    return ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
      // Header
      SizedBox(height: 72, child: Row(children: [
        SvgPicture.asset('assets/brand/mark.svg', width: 34, height: 34, semanticsLabel: 'Ritmia'),
        const SizedBox(width: 12),
        ExcludeSemantics(child: Text('ritmia', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.8, color: t.textPrimary))),
        const Spacer(),
        IconButton(tooltip: s.settings, onPressed: () => _openSettings(all, plan),
          icon: Icon(Icons.settings_outlined, size: 28, color: iconColor)),
      ])),
      const SizedBox(height: 20),
      // Monthly overview: plain typography, one line per currency (never summed across currencies).
      Text(s.thisMonth.toUpperCase(), style: TextStyle(fontSize: 13, letterSpacing: 1.4, fontWeight: FontWeight.w500, color: t.textSecondary)),
      const SizedBox(height: 4),
      if (totals.isEmpty) Text(s.noCharges, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: t.textPrimary))
      else for (final e in totals.entries) Semantics(label: context.amountWithCode(e.value, e.key), child: ExcludeSemantics(child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(context.amount(e.value, e.key),
            style: TextStyle(fontSize: totals.length > 1 ? 44 : 60, height: 1.1, fontWeight: FontWeight.w700, letterSpacing: -2,
              color: t.textPrimary, fontFeatures: BrandTheme.tabular)))),
          const SizedBox(width: 8),
          Text(e.key, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: t.textPrimary)),
        ]))),
      const SizedBox(height: 4),
      Text(s.subscriptionCount(all.length), style: TextStyle(fontSize: 16, color: t.textSecondary)),
      const SizedBox(height: 32),
      // Month + compact week strip
      Row(children: [
        Semantics(button: true, label: s.openCalendar, child: InkWell(borderRadius: BorderRadius.circular(8), onTap: () => showCalendarSheet(context),
          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 48), child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(context.monthName(today), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary)),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: t.textPrimary),
          ])))),
        const Spacer(),
        IconButton(tooltip: s.openCalendar, onPressed: () => showCalendarSheet(context),
          icon: Icon(Icons.calendar_today_outlined, size: 26, color: iconColor)),
      ]),
      const SizedBox(height: 12),
      Row(children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day == today;
        final has = week.containsKey(dateKey(day));
        return Expanded(child: Semantics(button: true, selected: isToday, label: context.longDay(day),
          child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => showCalendarSheet(context, initial: day),
            child: Column(children: [
              Text(context.weekdayInitial(i), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.textSecondary)),
              const SizedBox(height: 8),
              Container(width: 42, height: 34, alignment: Alignment.center,
                decoration: BoxDecoration(color: isToday ? t.selectedDay : null, borderRadius: BorderRadius.circular(10)),
                child: Text('${day.day}', style: TextStyle(fontSize: 17, fontFeatures: BrandTheme.tabular,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400, color: isToday ? t.onSelectedDay : t.textPrimary))),
              const SizedBox(height: 8),
              RenewalDot(visible: has, today: isToday),
              const SizedBox(height: 4),
            ]))));
      })),
      const SizedBox(height: 16),
      const Hairline(),
      const SizedBox(height: 16),
      // List
      Row(children: [
        Expanded(child: Semantics(header: true, child: Text(s.subscriptionsHeading,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary)))),
        IconButton(tooltip: s.search, onPressed: () => setState(() {
          _searching = !_searching;
          if (!_searching) { _search.clear(); _query = ''; }
        }), icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded, size: 27, color: iconColor)),
        IconButton(tooltip: s.filter, onPressed: _openFilter, icon: Badge(isLabelVisible: _filter != 'all', smallSize: 7,
          backgroundColor: t.dotToday, child: Icon(Icons.tune_rounded, size: 27, color: iconColor))),
      ]),
      if (_searching) Padding(padding: const EdgeInsets.only(top: 8, bottom: 4), child: TextField(controller: _search, autofocus: true,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(hintText: s.search, isDense: true, prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)))),
      const SizedBox(height: 4),
      if (all.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [
        Text(s.emptyTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: t.textPrimary)),
        const SizedBox(height: 10),
        Text(s.emptyBody, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.45, color: t.textSecondary)),
      ]))
      else if (visible.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(s.noResults, textAlign: TextAlign.center, style: TextStyle(color: t.textSecondary)))
      else for (var i = 0; i < visible.length; i++) ...[
        SubscriptionRow(item: visible[i], onTap: () => showDetailSheet(context, visible[i])),
        if (i < visible.length - 1) const Hairline(),
      ],
      const SizedBox(height: 16),
    ]);
  }
}
