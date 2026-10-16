import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/reminder_providers.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../../services/notification_service.dart';
import 'sheet.dart';

/// Explains reminders first; only after "Turn on" does the OS permission dialog appear.
/// Returns true when reminders end up enabled.
Future<bool> askForReminders(BuildContext context, WidgetRef ref) async {
  // Straight to the system permission prompt: granted → on, otherwise it stays off.
  final s = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final outcome = await ref.read(deviceAlertsProvider.notifier).setEnabled(true);
  if (outcome == PermissionOutcome.granted) {
    messenger?.showSnackBar(SnackBar(content: Text(s.permGranted)));
    return true;
  }
  if (outcome == PermissionOutcome.denied) {
    // Android stops showing the prompt after repeated denials; offer its notification page.
    messenger?.showSnackBar(SnackBar(content: Text(s.permBlockedBanner), duration: const Duration(seconds: 6),
      action: SnackBarAction(label: s.openPhoneSettings, onPressed: () => NotificationService.instance.openSystemSettings())));
  }
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
    FilledButton.icon(onPressed: () async {
      Navigator.pop(c);
      await NotificationService.instance.openSystemSettings();
    }, icon: const Icon(Icons.open_in_new_rounded, size: 20), label: Text(s.openPhoneSettings)),
    const SizedBox(height: 4),
    TextButton(onPressed: () => Navigator.pop(c), style: TextButton.styleFrom(foregroundColor: t.textPrimary), child: Text(s.permLater)),
  ]));
});
