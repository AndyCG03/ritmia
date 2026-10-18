import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:share_plus/share_plus.dart';
import '../core/environment.dart';
import '../core/errors.dart';
import '../core/features.dart';
import '../core/providers.dart';
import '../core/reminder_providers.dart';
import '../core/theme.dart';
import '../domain/export.dart';
import '../domain/calendar_export.dart';
import '../services/calendar_service.dart';
import '../core/supported_languages.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
import '../services/notification_service.dart';
import 'sheets/permission_sheet.dart';
import 'sheets/pro_sheet.dart';
import 'sheets/sheet.dart';

final emailPreferencesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authProvider).asData?.value;
  if (!Environment.cloud || user == null) return Stream.value({});
  return FirebaseFirestore.instance.doc('users/${user.uid}/private/preferences').snapshots().map((d) => d.data() ?? {});
});

/// Settings, shown inside a bottom sheet: grouped sections with icon tiles and clear summaries.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.items, required this.plan});
  final List<Subscription> items;
  final Entitlement plan;
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  Future<void> _action(Future<void> Function() action) async {
    setState(() => _busy = true);
    try { await action(); } catch (error) { if (mounted) showFailure(context, error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _email(bool enabled) async {
    final zone = await FlutterTimezone.getLocalTimezone();
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    await FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable('setReminderPreferences')
      .call({'emailEnabled': enabled, 'timeZone': zone.identifier, 'locale': locale});
  }

  Future<void> _export() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    final bytes = Uint8List.fromList(utf8.encode(exportCsv(widget.items)));
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'text/csv', name: 'ritmia.csv')],
      fileNameOverrides: ['ritmia.csv'], sharePositionOrigin: origin));
  }

  Future<void> _chooseLanguage(bool emailEnabled) async {
    final s = context.l10n, current = ref.read(localeProvider)?.languageCode ?? 'system';
    final choice = await showRitmiaSheet<String>(context, builder: (c) => Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: Text(s.language, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: c.tokens.textPrimary))), const SheetCloseButton()]),
        for (final (v, l) in [('system', s.system), ...languageNames.entries.map((e) => (e.key, e.value))]) ...[
          InkWell(onTap: () => Navigator.pop(c, v), child: SizedBox(height: 56, child: Row(children: [
            Expanded(child: Text(l, style: TextStyle(fontSize: 17, color: c.tokens.textPrimary))),
            if (v == current) Icon(Icons.check_rounded, color: c.tokens.textAction),
          ]))),
          const Hairline(),
        ],
      ])));
    if (choice == null) return;
    await _action(() async {
      await ref.read(localeProvider.notifier).setLocale(choice == 'system' ? null : Locale(choice));
      if (emailEnabled && mounted) await _email(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n, t = context.tokens, user = ref.watch(authProvider).asData?.value;
    final emailState = ref.watch(emailPreferencesProvider);
    final emailEnabled = emailState.asData?.value['emailEnabled'] == true;
    final alerts = ref.watch(deviceAlertsProvider);
    final blocked = ref.watch(systemBlockedProvider).asData?.value == true;
    final locale = ref.watch(localeProvider)?.languageCode;
    final used = widget.items.length, limit = widget.plan.subscriptionLimit;
    final proEnabled = ref.watch(proFeatureProvider);

    return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 0, 0, 16), child: Row(children: [
        Expanded(child: Semantics(header: true, child: Text(s.settings, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: t.textPrimary)))),
        const SheetCloseButton(),
      ])),

      // Plan
      _Group(children: [Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.proBenefitUnlimitedTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: t.textPrimary))),
          Text('$used', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary, fontFeatures: BrandTheme.tabular)),
        ]),
        const SizedBox(height: 6),
        Text(s.subscriptionCount(used), style: TextStyle(fontSize: 14, color: t.textSecondary)),
      ]))]),

      _Header(s.general),
      _Group(children: [
        _Row(icon: Icons.contrast_rounded, title: s.appearanceSummary, trailing: const SizedBox.shrink()),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: SizedBox(width: double.infinity, child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false, selected: {ref.watch(themeModeProvider)},
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(s.system)),
            ButtonSegment(value: ThemeMode.light, label: Text(s.themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
          ], onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).set(v.first)))),
        const Hairline(indent: 68),
        _Row(icon: Icons.translate_rounded, title: s.languageSummary,
          value: languageNames[locale] ?? s.system,
          onTap: _busy ? null : () => _chooseLanguage(emailEnabled)),
      ]),

      _Header(s.notificationsSection),
      _Group(children: [
        if (NotificationService.instance.supported) ...[
          _Row(icon: alerts && !blocked ? Icons.notifications_active_outlined : Icons.notifications_none_rounded,
            title: s.notificationToggle,
            subtitle: blocked ? s.notifBlockedSummary : alerts ? s.notifOnSummary : s.notifOffSummary,
            trailing: Switch(value: alerts, onChanged: _busy ? null : (enabled) => _action(() async {
              if (enabled) { await askForReminders(context, ref); }
              else { await ref.read(deviceAlertsProvider.notifier).setEnabled(false); }
              ref.invalidate(systemBlockedProvider);
            }))),
        ] else Padding(padding: const EdgeInsets.all(16), child: Text(kIsWeb ? s.webNotificationHelp : s.notificationHelp,
          style: TextStyle(fontSize: 14, color: t.textSecondary))),
        if (Environment.cloud) ...[
          const Hairline(indent: 68),
          _Row(icon: Icons.mail_outline_rounded, title: s.emailToggle, subtitle: s.emailHelp,
            trailing: Switch(value: emailEnabled, onChanged: _busy || emailState.isLoading ? null : (v) => _action(() => _email(v)))),
        ],
      ]),
      if (alerts && ref.watch(reminderSyncProvider).hasError) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), child: Row(children: [
          Expanded(child: Text(s.notifScheduleError, style: TextStyle(color: t.danger, fontSize: 13))),
          TextButton(onPressed: () => ref.invalidate(reminderSyncProvider), child: Text(s.retry)),
        ])),
      if (NotificationService.instance.supported) Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
        child: Text(s.notificationHelp, style: TextStyle(fontSize: 13, height: 1.4, color: t.textSecondary))),

      _Header(s.dataSection),
      _Group(children: [
        _Row(icon: Icons.event_available_outlined, title: s.calendarExport, subtitle: s.calendarExportHelp,
          onTap: _busy ? null : () => _action(() async {
            final now = dateOnly(DateTime.now());
            final entries = subscriptionCalendarEntries(widget.items, now, DateTime(now.year + 1, now.month, now.day));
            if (entries.isEmpty) { showInfo(context, s.calendarNoDates); return; }
            await CalendarService.shareDates(context, entries);
          })),
        const Hairline(indent: 68),
        _Row(icon: Icons.file_download_outlined, title: s.export, subtitle: s.exportHelp, onTap: _busy ? null : () => _action(_export)),
      ]),

      if (user != null) ...[
        _Header(s.account),
        _Group(children: [
          _Row(icon: user.emailVerified ? Icons.verified_outlined : Icons.email_outlined, title: user.email ?? '',
            subtitle: user.emailVerified ? s.verified : s.verifyEmail,
            onTap: user.emailVerified || _busy ? null : () => _action(() async {
              await user.sendEmailVerification();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.verificationSent)));
            })),
          const Hairline(indent: 68),
          _Row(icon: Icons.logout_rounded, title: s.signOut, iconColor: t.danger, onTap: _busy ? null : () => _action(() async {
            final ok = await showConfirmSheet(context, icon: Icons.logout_rounded, title: s.signOut, body: s.privacy, confirmLabel: s.signOut);
            if (!ok) return;
            await NotificationService.instance.sync([], false, const Locale('en'));
            await FirebaseAuth.instance.signOut();
          })),
        ]),
      ],

      const SizedBox(height: 28),
      Text(s.privacy, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.4, color: t.textSecondary)),
      const SizedBox(height: 6),
      Text('Ritmia · 1.2.3', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
    ]);
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(4, 28, 4, 10),
    child: Text(text.toUpperCase(), style: TextStyle(fontSize: 12.5, letterSpacing: 1.3, fontWeight: FontWeight.w600, color: context.tokens.textSecondary)));
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: context.tokens.field, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.tokens.separator.withValues(alpha: 0.5))),
    child: Material(type: MaterialType.transparency, child: Column(children: children)));
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, this.subtitle, this.value, this.trailing, this.onTap, this.iconColor});
  final IconData icon;
  final String title;
  final String? subtitle, value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(onTap: onTap, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 60), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: t.tile, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor ?? t.textPrimary)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: t.textPrimary)),
          if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!, style: TextStyle(fontSize: 13.5, height: 1.35, color: t.textSecondary))),
        ])),
        if (value != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(value!, style: TextStyle(fontSize: 15, color: t.textSecondary))),
        trailing ?? (onTap != null ? Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.chevron_right_rounded, color: t.textSecondary)) : const SizedBox.shrink()),
      ]))));
  }
}
