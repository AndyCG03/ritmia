import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/reminder_providers.dart';
import '../../core/errors.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../../services/notification_service.dart';
import 'sheet.dart';

/// Requests permission directly through the OS.
/// Returns true when reminders end up enabled.
Future<bool> askForReminders(BuildContext context, WidgetRef ref, {bool showConfirmation = true}) async {
  // Straight to the system permission prompt: granted → on, otherwise it stays off.
  final s = context.l10n;
  final PermissionOutcome outcome;
  try {
    outcome = await ref.read(deviceAlertsProvider.notifier).setEnabled(true);
  } catch (error) {
    if (showConfirmation && context.mounted) showFailure(context, error);
    return false;
  }

  if (outcome == PermissionOutcome.granted) {
    if (showConfirmation && context.mounted) showSuccess(context, s.permGranted);
    return true;
  }

  if (outcome == PermissionOutcome.denied && showConfirmation) {
    // If permission is denied, the system dialog might have been suppressed or the user clicked "deny".
    // Show the blocked sheet immediately to explain how to enable them in settings.
    if (context.mounted) await showBlockedSheet(context);
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
