import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/subscription.dart';
import '../../l10n/context.dart';
import '../widgets/subscription_row.dart';
import 'detail_sheet.dart';
import 'sheet.dart';

/// Renewals keyed by civil date (YYYY-MM-DD) in [from, until).
Map<String, List<Subscription>> renewalsBetween(List<Subscription> items, DateTime from, DateTime until) {
  final events = <String, List<Subscription>>{};
  for (final item in items) {
    for (final d in item.occurrences(from, until)) {
      events.putIfAbsent(dateKey(d), () => []).add(item);
    }
  }
  return events;
}

/// Small renewal dot: coral when it is today's charge, lavender otherwise.
class RenewalDot extends StatelessWidget {
  const RenewalDot({super.key, required this.visible, required this.today, this.onSelected = false});
  final bool visible, today, onSelected;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(height: 6, width: 6, child: visible ? DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle,
      color: today ? t.dotToday : onSelected ? t.onSelectedDay : t.dotOther)) : null);
  }
}

Future<void> showCalendarSheet(BuildContext context, {DateTime? initial}) =>
  showRitmiaSheet(context, maxFactor: 0.9, builder: (_) => CalendarSheet(initial: initial ?? DateTime.now()));

class CalendarSheet extends ConsumerStatefulWidget {
  const CalendarSheet({super.key, required this.initial});
  final DateTime initial;
  @override
  ConsumerState<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends ConsumerState<CalendarSheet> {
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);
  late DateTime _selected = dateOnly(widget.initial);

  void _move(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    final today = dateOnly(DateTime.now());
    _selected = today.year == _month.year && today.month == _month.month ? today : _month;
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    final items = ref.watch(subscriptionsProvider).asData?.value ?? const <Subscription>[];
    final today = dateOnly(DateTime.now());
    final events = renewalsBetween(items, _month, DateTime(_month.year, _month.month + 1));
    final leading = _month.weekday - 1;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((leading + days) / 7).ceil();
    final selected = events[dateKey(_selected)] ?? const <Subscription>[];
    final head = TextStyle(fontSize: 14, color: t.textSecondary, fontWeight: FontWeight.w500);

    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconButton(tooltip: s.previousMonth, onPressed: () => _move(-1), icon: Icon(Icons.chevron_left_rounded, color: t.textPrimary)),
          Expanded(child: Semantics(header: true, liveRegion: true, child: Text(context.monthYear(_month), textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary, fontFeatures: BrandTheme.tabular)))),
          IconButton(tooltip: s.nextMonth, onPressed: () => _move(1), icon: Icon(Icons.chevron_right_rounded, color: t.textPrimary)),
          const SizedBox(width: 16),
          TextButton(onPressed: () => setState(() { _selected = today; _month = DateTime(today.year, today.month); }), child: Text(s.today)),
          const SheetCloseButton(),
        ]),
        const SizedBox(height: 16),
        Row(children: List.generate(7, (i) => Expanded(child: Center(child: Text(context.weekdayInitial(i), style: head))))),
        const SizedBox(height: 8),
        for (var r = 0; r < rows; r++) Row(children: List.generate(7, (c) {
          final day = r * 7 + c - leading + 1;
          if (day < 1 || day > days) return const Expanded(child: SizedBox(height: 56));
          final date = DateTime(_month.year, _month.month, day);
          final key = dateKey(date);
          final isSelected = key == dateKey(_selected), isToday = key == dateKey(today);
          final daily = events[key] ?? const <Subscription>[];
          return Expanded(child: Semantics(button: true, selected: isSelected,
            label: '${context.longDay(date)}, ${daily.length}',
            child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() => _selected = date),
              child: SizedBox(height: 56, child: Center(child: Container(width: 48, height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  color: isSelected ? t.selectedDay : null,
                  border: isToday && !isSelected ? Border.all(color: t.separator) : null),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('$day', style: TextStyle(fontSize: 17, fontFeatures: BrandTheme.tabular,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? t.onSelectedDay : t.textPrimary)),
                  const SizedBox(height: 4),
                  RenewalDot(visible: daily.isNotEmpty, today: isToday, onSelected: isSelected),
                ])))))));
        })),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Hairline()),
        Padding(padding: const EdgeInsets.fromLTRB(8, 24, 8, 8), child: Text(context.longDay(_selected),
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: t.textPrimary))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Column(children: [
          if (selected.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(s.noEvents, style: TextStyle(fontSize: 15, color: t.textSecondary))))
          else for (final item in selected) ...[
            SubscriptionRow(item: item, compactTrailing: true, subtitle: context.renewalLabel(item.cycle),
              onTap: () => showDetailSheet(context, item)),
            const Hairline(),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 22, color: t.textSecondary),
            const SizedBox(width: 20),
            Expanded(child: Text(s.tapDateHint, style: TextStyle(fontSize: 15, color: t.textSecondary))),
          ]),
        ])),
      ]));
  }
}
