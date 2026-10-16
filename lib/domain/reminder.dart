import 'subscription.dart';
enum ReminderKind { renewal, trial, ending }
class ReminderEvent {
  const ReminderEvent(this.subscription, this.date, this.target, this.kind, this.leadDays);
  final Subscription subscription;
  final DateTime date, target;
  final ReminderKind kind;
  final int leadDays;
  String get key => '${subscription.id}:${kind.name}:${dateKey(target)}:$leadDays';
}
List<ReminderEvent> upcomingReminders(List<Subscription> items, DateTime now, {int horizonDays = 60}) {
  final horizon = DateTime(now.year, now.month, now.day + horizonDays);
  final events = <ReminderEvent>[];
  for (final s in items.where((s) => s.status == SubscriptionStatus.active)) {
    final targets = <(DateTime, ReminderKind)>[
      for (final d in s.renewals(dateOnly(now), DateTime(horizon.year,horizon.month,horizon.day + 14))) (d, ReminderKind.renewal),
      if (s.trialEndsOn != null) (DateTime.parse(s.trialEndsOn!), ReminderKind.trial),
      if (s.endsOn != null) (DateTime.parse(s.endsOn!), ReminderKind.ending),
    ];
    for (final (target, kind) in targets) {
      for (final lead in s.reminderDays.toSet()) {
        final date = DateTime(target.year, target.month, target.day - lead, 9);
        if (date.isAfter(now) && date.isBefore(horizon)) events.add(ReminderEvent(s, date, target, kind, lead));
      }
    }
  }
  events.sort((a,b) => a.date.compareTo(b.date));
  return events;
}
