import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/domain/subscription.dart';
import 'package:ritmia/domain/renewal_priority.dart';

Subscription item(String id, String anchor, {String? end, SubscriptionStatus status = SubscriptionStatus.active}) =>
  Subscription(id: id, name: id, amountMinor: 100, currency: 'USD', free: false,
    anchorDate: anchor, cycle: BillingCycle.monthly, color: 0, endsOn: end, status: status);

void main() {
  final now = DateTime(2026, 10, 16);
  test('cancellation deadlines lead, then renewals, then inactive records', () {
    final items = [item('renew-later', '2026-10-23'), item('stop-later', '2026-09-30', end: '2026-10-30'),
      item('paused', '2026-10-16', status: SubscriptionStatus.paused), item('renew-soon', '2026-10-17'),
      item('stop-soon', '2026-09-20', end: '2026-10-20')];
    expect(prioritizeRenewals(items, now).map((s) => s.id),
      ['stop-soon', 'stop-later', 'renew-soon', 'renew-later', 'paused']);
    expect(priorityDate(items[1], now), DateTime(2026, 10, 30));
  });
  test('overdue cancellation stays visible until the user confirms what happened', () {
    final overdue = item('overdue', '2026-08-01', end: '2026-10-01');
    expect(prioritizeRenewals([item('soon', '2026-10-16'), overdue], now).first.id, 'overdue');
    expect(overdue.nextRenewal(now), isNull);
  });
  test('ties stay deterministic without mutating input', () {
    final items = [item('z', '2026-10-18'), item('a', '2026-10-18')];
    expect(prioritizeRenewals(items, now).map((s) => s.id), ['a', 'z']);
    expect(items.first.id, 'z');
  });
}
