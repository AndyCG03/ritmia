import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/calendar_export.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
import '../l10n/generated/app_localizations.dart';

class CalendarService {
  static const _channel = MethodChannel('app.ritmia/calendar');
  static String title(CalendarEntry e, AppLocalizations s) => switch (e.kind) {
    CalendarEntryKind.renewal => s.calendarRenewalTitle(e.subscription.name),
    CalendarEntryKind.trial => s.calendarTrialTitle(e.subscription.name),
    CalendarEntryKind.cancellation => s.calendarCancelTitle(
      e.subscription.name,
    ),
  };
  static String description(BuildContext context, CalendarEntry e) =>
      '${e.subscription.free ? context.l10n.free : context.amountWithCode(e.subscription.amountMinor, e.subscription.currency)}\n\n${context.l10n.calendarEventHelp}';

  /// Opens the calendar's own editor; Ritmia never writes calendar data silently.
  static Future<bool> addDate(BuildContext context, Subscription item) async {
    final now = dateOnly(DateTime.now());
    final entries = subscriptionCalendarEntries(
      [item],
      now,
      DateTime(now.year + 2, now.month, now.day),
    );
    if (entries.isEmpty) return false;
    final e = item.stopsRenewing
        ? entries
                  .where((e) => e.kind == CalendarEntryKind.cancellation)
                  .firstOrNull ??
              entries.first
        : entries.first;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final opened =
          await _channel.invokeMethod<bool>('insertEvent', {
            'title': title(e, context.l10n),
            'description': description(context, e),
            'begin': DateTime.utc(
              e.date.year,
              e.date.month,
              e.date.day,
            ).millisecondsSinceEpoch,
            'end': DateTime.utc(
              e.date.year,
              e.date.month,
              e.date.day + 1,
            ).millisecondsSinceEpoch,
          }) ??
          false;
      if (opened) return true;
    }
    if (context.mounted) await shareDates(context, entries);
    return true;
  }

  static Future<void> shareDates(
    BuildContext context,
    List<CalendarEntry> entries,
  ) async {
    final s = context.l10n;
    final ics = exportIcalendar(
      entries.take(1000).toList(),
      generatedAt: DateTime.now(),
      title: (e) => title(e, s),
      description: (e) => description(context, e),
    );
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(ics)),
            mimeType: 'text/calendar',
            name: 'ritmia.ics',
          ),
        ],
        fileNameOverrides: ['ritmia.ics'],
        sharePositionOrigin: origin,
      ),
    );
  }
}
