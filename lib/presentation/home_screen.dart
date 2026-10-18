import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/ritmia_logo.dart';
import 'widgets/bottom_action.dart';
import 'widgets/monthly_overview.dart';
import '../core/errors.dart';
import '../core/features.dart';
import '../core/providers.dart';
import '../core/guided_tour_provider.dart';
import 'widgets/guided_tour.dart';
import '../core/theme.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../domain/renewal_priority.dart';
import '../l10n/context.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';
import 'sheets/calendar_sheet.dart';
import 'sheets/catalog_sheet.dart';
import 'sheets/detail_sheet.dart';
import 'sheets/pro_sheet.dart';
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
    ref.read(guidedTourProvider.notifier).withModal(()=>showDetailSheet(context,item));
  }

  @override
  void dispose() {
    NotificationService.instance.openedSubscription.removeListener(_openFromNotification);
    _search.dispose(); super.dispose();
  }

  void _add(int count, Entitlement plan) {
    if (!plan.canCreate(count)) {
      final inTour = ref.read(guidedTourProvider).step != null;
      ref.read(guidedTourProvider.notifier).advanceIf(TourStep.add,TourStep.record);
      if (context.mounted) {
        showInfo(context, context.l10n.limitMessage);
        if (!inTour && ref.read(proFeatureProvider)) showProSheet(context);
      }
      return;
    }
    showCatalogSheet(context);
  }

  void _openSettings(List<Subscription> items, Entitlement plan) {
    final tour=ref.read(guidedTourProvider.notifier);
    if(ref.read(guidedTourProvider).step==TourStep.settings) tour.finish();
    showRitmiaSheet(context,heightFactor:0.88,maxFactor:0.9,builder:(_)=>SettingsScreen(items:items,plan:plan));
  }

  Future<void> _openFilter() async {
    final s = context.l10n, tour=ref.read(guidedTourProvider.notifier);
    await tour.withModal(()=>showRitmiaSheet<void>(context, builder: (c) {
      final t = c.tokens;
      return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: Text(s.filter, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary))), const SheetCloseButton()]),
        const SizedBox(height: 8),
        for (final e in [('all', s.all), ('renews', s.willRenew), ('stops', s.stopRenewing)]) ...[
          InkWell(onTap: () { setState(() => _filter = e.$1); Navigator.pop(c); }, child: SizedBox(height: 56, child: Row(children: [
            Expanded(child: Text(e.$2, style: TextStyle(fontSize: 17, color: t.textPrimary))),
            if (_filter == e.$1) Icon(Icons.check_rounded, color: t.textAction),
          ]))),
          const Hairline(),
        ],
      ]));
    }));
    tour.advanceIf(TourStep.filter,TourStep.settings);
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
      child: Scaffold(body: SafeArea(bottom: false, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: Column(children: [
        Expanded(child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(errorMessage(context, error), textAlign: TextAlign.center),
            TextButton(onPressed: () => ref.invalidate(subscriptionsProvider), child: Text(s.retry)),
          ])),
          data: (_) => _content(items, plan))),
        BottomAction(child: TourAnchor(id:'add',child:FilledButton.icon(
          onPressed: data.asData == null ? null : () => _add(items.length, plan),
          icon: const Icon(Icons.add_rounded, size: 28), label: Text(s.add, maxLines: 1, overflow: TextOverflow.ellipsis)))),
      ]))))));
  }

  Widget _content(List<Subscription> all, Entitlement plan) {
    final s = context.l10n, t = context.tokens;
    final now = DateTime.now(), today = dateOnly(now);
    final totals = chargesInMonth(all, now);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final week = renewalsBetween(all, monday, monday.add(const Duration(days: 7)));
    final q = _query.toLowerCase();
    final visible = prioritizeRenewals(all.where((i) => '${i.name} ${i.notes}'.toLowerCase().contains(q) && switch (_filter) {
      'renews' => i.status == SubscriptionStatus.active && !i.stopsRenewing,
      'stops' => i.stopsRenewing, _ => true,
    }), now);
    final iconColor = t.textPrimary;

    return ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
      // Header
      SizedBox(height: 64, child: Row(children: [
        const RitmiaLogo(size: 34),
        const SizedBox(width: 12),
        ExcludeSemantics(child: Text('ritmia', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.8, color: t.textPrimary))),
        const Spacer(),
        TourAnchor(id:'settings',child:IconButton(tooltip: s.settings, onPressed: () => _openSettings(all, plan),
          icon: Icon(Icons.settings_outlined, size: 28, color: iconColor))),
      ])),
      const SizedBox(height: 12),
      MonthlyOverview(totals: totals, count: all.length),
      const SizedBox(height: 18),
      // Month + compact week strip
      Row(children: [
        Semantics(button: true, label: s.openCalendar, child: InkWell(borderRadius: BorderRadius.circular(8), onTap: () => showCalendarSheet(context),
          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 48), child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(context.monthName(today), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary)),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: t.textPrimary),
          ])))),
        const Spacer(),
        TourAnchor(id:'calendar',child:IconButton(tooltip:s.openCalendar,onPressed:() async {
          final tour=ref.read(guidedTourProvider.notifier);
          await tour.withModal(()=>showCalendarSheet(context));
          tour.advanceIf(TourStep.calendar,TourStep.filter);
        },icon:Icon(Icons.calendar_today_outlined,size:26,color:iconColor))),
      ]),
      const SizedBox(height: 8),
      Row(children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day == today;
        final has = !day.isBefore(today) && week.containsKey(dateKey(day));
        final bought = all.any((i) => dateKey(i.purchaseDate) == dateKey(day));
        final deadline = all.any((i) => i.stopsRenewing && i.endsOn == dateKey(day));
        return Expanded(child: Semantics(button: true, selected: isToday, label: context.longDay(day),
          child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => showCalendarSheet(context, initial: day),
            child: Column(children: [
              Text(context.weekdayInitial(i), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.textSecondary)),
              const SizedBox(height: 8),
              Container(width: 42, height: 34, alignment: Alignment.center,
                decoration: BoxDecoration(color: isToday ? (deadline ? t.alert : t.selectedDay) : deadline ? t.alert.withValues(alpha: 0.12) : null,
                  borderRadius: BorderRadius.circular(10)),
                child: Text('${day.day}', style: TextStyle(fontSize: 17, fontFeatures: BrandTheme.tabular,
                  fontWeight: isToday || deadline ? FontWeight.w600 : FontWeight.w400,
                  color: isToday ? t.onSelectedDay : deadline ? t.alert : t.textPrimary))),
              const SizedBox(height: 8),
              deadline ? Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: t.alert))
                : bought ? Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: t.purchase))
                : RenewalDot(visible: has, today: isToday),
              const SizedBox(height: 4),
            ]))));
      })),
      const SizedBox(height: 12),
      const Hairline(),
      const SizedBox(height: 12),
      // List
      Row(children: [
        Expanded(child: Semantics(header: true, child: Text(s.subscriptionsHeading,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary)))),
        IconButton(tooltip: s.search, onPressed: () => setState(() {
          _searching = !_searching;
          if (!_searching) { _search.clear(); _query = ''; }
        }), icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded, size: 27, color: iconColor)),
        TourAnchor(id:'filter',child:IconButton(tooltip: s.filter, onPressed: _openFilter, icon: Badge(isLabelVisible: _filter != 'all', smallSize: 7,
          backgroundColor: t.dotToday, child: Icon(Icons.tune_rounded, size: 27, color: iconColor)))),
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
        if(i==0) TourAnchor(id:'record',child:SubscriptionRow(item:visible[i],onTap:() async {
          final tour=ref.read(guidedTourProvider.notifier);
          await tour.withModal(()=>showDetailSheet(context,visible[i]));
        })) else SubscriptionRow(item:visible[i],onTap:()=>showDetailSheet(context,visible[i])),
        if (i < visible.length - 1) const Hairline(),
      ],
      const SizedBox(height: 16),
    ]);
  }
}
