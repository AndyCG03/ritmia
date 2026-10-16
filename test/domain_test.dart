import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/domain/export.dart';
import 'package:ritmia/domain/reminder.dart';
import 'package:ritmia/domain/repositories.dart';
import 'package:ritmia/domain/subscription.dart';
Subscription item({String anchor='2024-01-31',BillingCycle cycle=BillingCycle.monthly,String currency='USD',int amount=1299,bool free=false,SubscriptionStatus status=SubscriptionStatus.active,String? end,String? trial})=>
  Subscription(id:'abcdefghijklmnopqrst',name:'Sample',amountMinor:amount,currency:currency,free:free,anchorDate:anchor,cycle:cycle,color:0xFF282338,status:status,endsOn:end,trialEndsOn:trial);
void main(){
  test('month end returns to anchor after February',(){
    final s=item();expect(dateKey(s.occurrence(1)),'2024-02-29');expect(dateKey(s.occurrence(2)),'2024-03-31');
    expect(dateKey(item(anchor:'2025-01-31').occurrence(1)),'2025-02-28');
  });
  test('leap year annual renewal returns to February 29',(){
    final s=item(anchor:'2024-02-29',cycle:BillingCycle.yearly);
    expect(dateKey(s.occurrence(1)),'2025-02-28');expect(dateKey(s.occurrence(4)),'2028-02-29');
  });
  test('quarterly and weekly recurrence',(){
    expect(dateKey(item(cycle:BillingCycle.quarterly).occurrence(1)),'2024-04-30');
    expect(dateKey(item(anchor:'2026-03-01',cycle:BillingCycle.weekly).occurrence(2)),'2026-03-15');
  });
  test('next renewal includes today, future anchors and inactive states',(){
    expect(dateKey(item().nextRenewal(DateTime(2024,2,29,23))!),'2024-02-29');
    expect(dateKey(item(anchor:'2027-01-01').nextRenewal(DateTime(2026,1,1))!),'2027-01-01');
    expect(item(status:SubscriptionStatus.paused).nextRenewal(DateTime(2024)),isNull);
  });
  test('end date prevents further renewals including same day',(){
    final events=item(end:'2024-03-31').occurrences(DateTime(2024),DateTime(2025));
    expect(events.map(dateKey),['2024-01-31','2024-02-29']);
  });
  test('integer amounts, decimal comma and zero-decimal currencies',(){
    expect(parseAmount('12,99','EUR'),1299);expect(parseAmount('0.10','USD'),10);
    expect(parseAmount('1200','JPY'),1200);expect(parseAmount('12.50','JPY'),isNull);
    for(final value in ['1,299.00','-4','2.999','NaN','Infinity','1e3','']){expect(parseAmount(value,'USD'),isNull);}
  });
  test('month totals preserve currencies and count every weekly charge',(){
    final totals=chargesInMonth([item(anchor:'2026-10-01',cycle:BillingCycle.weekly,amount:1000),
      item(anchor:'2026-10-16',currency:'EUR',amount:500),item(anchor:'2026-10-01',free:true,amount:0)],DateTime(2026,10));
    expect(totals,{'USD':5000,'EUR':500});
  });
  test('free quota and pro grants',(){
    expect(const Entitlement().canCreate(4),isTrue);expect(const Entitlement().canCreate(5),isFalse);
    expect(const Entitlement(pro:true).canCreate(500),isTrue);
  });
  test('reminders use future 9am civil dates and include trial/end',(){
    final s=item(anchor:'2026-10-20',end:'2026-11-20',trial:'2026-10-19');
    final events=upcomingReminders([s],DateTime(2026,10,16,10));
    expect(events.any((e)=>e.kind==ReminderKind.renewal&&e.date==DateTime(2026,10,17,9)),isTrue);
    expect(events.any((e)=>e.kind==ReminderKind.trial&&e.target==DateTime(2026,10,19)),isTrue);
    expect(events.any((e)=>e.kind==ReminderKind.ending),isTrue);
    expect(events.every((e)=>e.date.isAfter(DateTime(2026,10,16,10))),isTrue);
    expect(events.map((e)=>e.key).toSet().length,events.length);
  });
  test('paused subscriptions produce no reminders',(){
    expect(upcomingReminders([item(status:SubscriptionStatus.paused)],DateTime(2024)),isEmpty);
  });
  test('serialization preserves reminders, images and category',(){
    final s=item(end:'2026-12-01',trial:'2026-01-01').withLogo(null,bytes:'abc');
    expect(Subscription.fromJson(s.toJson()).toJson(),s.toJson());
  });
  test('CSV quotes content and prevents spreadsheet formula injection',(){
    final s=Subscription.fromJson({...item().toJson(),'name':'=HYPERLINK("evil")','notes':'line 1\nline 2'});
    final csv=exportCsv([s]);expect(csv,contains("'=HYPERLINK"));expect(csv,contains('""evil""'));
    expect(csv,startsWith('\uFEFF'));expect(csv,contains('amount_minor'));
  });
}
