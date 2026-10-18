import 'subscription.dart';

/// Cancellation intent takes priority; within each group the nearest civil date wins.
/// Overdue cancellation deadlines stay visible until the user updates the record.
DateTime? priorityDate(Subscription item, DateTime now) =>
    item.status != SubscriptionStatus.active ? null
    : item.stopsRenewing ? item.renewalDeadline : item.nextRenewal(now);

List<Subscription> prioritizeRenewals(Iterable<Subscription> items, DateTime now) {
  int group(Subscription s) => s.status != SubscriptionStatus.active ? 2 : s.stopsRenewing ? 0 : 1;
  return items.toList()..sort((a, b) {
    final intent = group(a).compareTo(group(b));
    if (intent != 0) return intent;
    final date = (priorityDate(a, now) ?? DateTime(9999)).compareTo(priorityDate(b, now) ?? DateTime(9999));
    if (date != 0) return date;
    final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return name != 0 ? name : a.id.compareTo(b.id);
  });
}
