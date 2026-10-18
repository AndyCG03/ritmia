import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/domain/subscription.dart';
import 'package:ritmia/domain/calendar_export.dart';

Subscription plan({String? trial,String? end,SubscriptionStatus status=SubscriptionStatus.active}) =>
  Subscription(id:'plan-1',name:'A',amountMinor:1000,currency:'USD',free:false,anchorDate:'2024-01-31',
    purchasedOn:'2024-01-31',cycle:BillingCycle.monthly,color:0,trialEndsOn:trial,endsOn:end,status:status);
void main() {
  test('calendar export follows month-end anchors and excludes the purchase day',(){
    final dates=subscriptionCalendarEntries([plan()],DateTime(2024,1),DateTime(2024,5));
    expect(dates.map((e)=>dateKey(e.date)),['2024-02-29','2024-03-31','2024-04-30']);
  });
  test('trial is one event; cancellation replaces the charge; inactive records are excluded',(){
    final dates=subscriptionCalendarEntries([plan(trial:'2024-02-29',end:'2024-03-31'),plan(status:SubscriptionStatus.paused)],DateTime(2024,1),DateTime(2024,5));
    expect(dates.map((e)=>e.kind),[CalendarEntryKind.trial,CalendarEntryKind.cancellation]);
  });
  test('ICS dates, exclusive end, stable UID, escaping and UTF8 folding',(){
    final e=CalendarEntry(plan(),DateTime(2024,2,29),CalendarEntryKind.renewal);
    final name='${List.filled(50,'Á').join()};\\x\r\nBEGIN:VEVENT';
    final ics=exportIcalendar([e],generatedAt:DateTime.utc(2024,1,1),title:(_)=>name,description:(_)=>'Note, test\nMore');
    expect(ics,contains('DTSTAMP:20240101T000000Z'));
    expect(ics,contains('DTSTART;VALUE=DATE:20240229'));
    expect(ics,contains('DTEND;VALUE=DATE:20240301'));
    expect(ics,contains('UID:${e.uid}'));
    expect(ics.split('\r\n').where((line)=>line=='BEGIN:VEVENT').length,1);
    expect(ics,contains(r'\;'));
    expect(ics,contains('TRIGGER:-P3D'));
    expect(ics.split('\r\n').every((line)=>utf8.encode(line).length<=75),isTrue);
    expect(ics.replaceAll('\r\n ',''),contains(r'\nBEGIN:VEVENT'));
  });
}
