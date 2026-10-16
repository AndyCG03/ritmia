import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../core/reminder_providers.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../../services/notification_service.dart';
import 'sheet.dart';

/// Explains reminders first; only after "Turn on" does the OS permission dialog appear.
/// Returns true when reminders end up enabled.
Future<bool> askForReminders(BuildContext context, WidgetRef ref) async {
  final s = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final accepted = await showRitmiaSheet<bool>(context, builder: (_) => const _ExplainSheet());
  if (accepted != true || !context.mounted) return false;
  final outcome = await ref.read(deviceAlertsProvider.notifier).setEnabled(true);
  if (!context.mounted) return false;
  if (outcome == PermissionOutcome.granted) {
    messenger?.showSnackBar(SnackBar(content: Text(s.permGranted)));
    return true;
  }
  if (outcome == PermissionOutcome.denied) await showBlockedSheet(context);
  return false;
}

Future<void> showBlockedSheet(BuildContext context) => showRitmiaSheet<void>(context, builder: (c) {
  final t = c.tokens, s = c.l10n;
  return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Icon(Icons.notifications_off_outlined, size: 40, color: t.danger),
    const SizedBox(height: 16),
    Text(s.permDeniedTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: t.textPrimary)),
    const SizedBox(height: 10),
    Text(s.permDeniedBody, style: TextStyle(fontSize: 16, height: 1.45, color: t.textSecondary)),
    const SizedBox(height: 24),
    FilledButton(onPressed: () => Navigator.pop(c), child: Text(s.understood)),
  ]));
});

class _ExplainSheet extends StatelessWidget {
  const _ExplainSheet();
  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n, reduce = MediaQuery.disableAnimationsOf(context);
    Widget point(IconData icon, String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: t.tile, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 22, color: t.textPrimary)),
      const SizedBox(width: 16),
      Expanded(child: Text(text, style: TextStyle(fontSize: 16, color: t.textPrimary))),
    ]));
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Container(width: 120, height: 120, decoration: BoxDecoration(color: BrandTheme.ink, borderRadius: BorderRadius.circular(32)),
        child: Lottie.asset('assets/lottie/bell.json', animate: !reduce, repeat: !reduce,
          errorBuilder: (_, _, _) => const Icon(Icons.notifications_none_rounded, color: BrandTheme.lavender, size: 48)))),
      const SizedBox(height: 20),
      Text(s.permTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: t.textPrimary)),
      const SizedBox(height: 10),
      Text(s.permBody, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.45, color: t.textSecondary)),
      const SizedBox(height: 16),
      point(Icons.schedule_rounded, s.permPointOne),
      point(Icons.phone_android_rounded, s.permPointTwo),
      point(Icons.toggle_off_outlined, s.permPointThree),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.permAllow)),
      const SizedBox(height: 4),
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.permLater)),
    ]));
  }
}
