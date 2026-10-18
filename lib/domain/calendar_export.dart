import 'dart:convert';

import 'subscription.dart';

enum CalendarEntryKind { renewal, trial, cancellation }

class CalendarEntry {
  const CalendarEntry(this.subscription, this.date, this.kind);
  final Subscription subscription;
  final DateTime date;
  final CalendarEntryKind kind;
  String get uid =>
      '${base64UrlEncode(utf8.encode(subscription.id)).replaceAll('=', '')}-${kind.name}-${dateKey(date)}@ritmia.app';
}

/// Explicit dates preserve anchor-based month ends; calendar RRULEs may skip short months.
List<CalendarEntry> subscriptionCalendarEntries(
  Iterable<Subscription> items,
  DateTime from,
  DateTime until,
) {
  final start = dateOnly(from), end = dateOnly(until);
  final result = <CalendarEntry>[];
  for (final item in items.where(
    (s) => s.status == SubscriptionStatus.active,
  )) {
    final trial = item.trialEndsOn == null
        ? null
        : DateTime.parse(item.trialEndsOn!);
    for (final date in item.renewals(start, end)) {
      if (trial != date) {
        result.add(CalendarEntry(item, date, CalendarEntryKind.renewal));
      }
    }
    for (final (date, kind) in [
      (trial, CalendarEntryKind.trial),
      (item.renewalDeadline, CalendarEntryKind.cancellation),
    ]) {
      if (date != null && !date.isBefore(start) && date.isBefore(end)) {
        result.add(CalendarEntry(item, date, kind));
      }
    }
  }
  result.sort((a, b) {
    final date = a.date.compareTo(b.date);
    if (date != 0) return date;
    final kind = b.kind.index.compareTo(a.kind.index);
    return kind != 0 ? kind : a.uid.compareTo(b.uid);
  });
  return result;
}

String _text(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll('\n', r'\n')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,');
String _date(DateTime date) => dateKey(date).replaceAll('-', '');

/// RFC 5545 folding counts UTF-8 octets, never splitting an accented character.
String _fold(String line) {
  final out = StringBuffer();
  var bytes = 0;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune),
        length = utf8.encode(String.fromCharCode(rune)).length;
    if (bytes + length > 75) {
      out.write('\r\n ');
      bytes = 1;
    }
    out.write(char);
    bytes += length;
  }
  return out.toString();
}

String exportIcalendar(
  List<CalendarEntry> entries, {
  required DateTime generatedAt,
  required String Function(CalendarEntry) title,
  required String Function(CalendarEntry) description,
}) {
  final stamp =
      '${generatedAt.toUtc().toIso8601String().replaceAll(RegExp(r"[-:]"), "").split(".").first.replaceAll("Z", "")}Z';
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Ritmia//Subscriptions//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
  ];
  for (final e in entries) {
    final summary = _text(title(e));
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${e.uid}',
      'DTSTAMP:$stamp',
      'DTSTART;VALUE=DATE:${_date(e.date)}',
      'DTEND;VALUE=DATE:${_date(DateTime(e.date.year, e.date.month, e.date.day + 1))}',
      'SUMMARY:$summary',
      'DESCRIPTION:${_text(description(e))}',
      'TRANSP:TRANSPARENT',
    ]);
    for (final days in e.subscription.reminderDays.toSet().where(
      (v) => v > 0 && v <= 14,
    )) {
      lines.addAll([
        'BEGIN:VALARM',
        'TRIGGER:-P${days}D',
        'ACTION:DISPLAY',
        'DESCRIPTION:$summary',
        'END:VALARM',
      ]);
    }
    lines.add('END:VEVENT');
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_fold).join('\r\n')}\r\n';
}
