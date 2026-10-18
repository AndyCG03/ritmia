import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/repositories.dart';
import '../l10n/context.dart';
import 'theme.dart';

String errorMessage(BuildContext context, Object error) {
  final s = context.l10n;
  final code = switch (error) {
    AppFailure(:final code) => code,
    FirebaseFunctionsException(:final code) => code,
    FirebaseAuthException(:final code) => code,
    PlatformException(:final code) => code,
    _ => 'unknown',
  };
  return switch (code) {
    'limit' || 'resource-exhausted' => s.limitMessage,
    'aborted' || 'conflict' => s.conflictMessage,
    'image' => s.imageError,
    'invalid_icon' || 'notification-initialization-failed' => s.notificationSetupError,
    'notifications-denied' => s.permissionDenied,
    'invalid-email' => s.invalidEmail,
    'weak-password' => s.weakPassword,
    'email-already-in-use' => s.emailInUse,
    'invalid-credential' || 'wrong-password' || 'user-not-found' => s.credentialsError,
    'too-many-requests' => s.tooManyRequests,
    'network-request-failed' || 'unavailable' => s.networkError,
    'failed-precondition' => s.preconditionError,
    _ => s.genericError,
  };
}

void showFailure(BuildContext context, Object error) => _show(context,
    message: errorMessage(context, error),
    icon: Icons.error_outline_rounded,
    color: context.tokens.danger);

void showSuccess(BuildContext context, String message) => _show(context,
    message: message,
    icon: Icons.check_circle_outline_rounded,
    color: context.tokens.textAction);

void showInfo(BuildContext context, String message, {SnackBarAction? action, Duration? duration}) =>
    _show(context, message: message, icon: Icons.info_outline_rounded, action: action, duration: duration);

void _show(BuildContext context,
    {required String message,
    required IconData icon,
    Color? color,
    SnackBarAction? action,
    Duration? duration}) {
  final t = context.tokens;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    backgroundColor: t.sheet,
    elevation: 8,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.separator.withValues(alpha: 0.5))),
    duration: duration ?? const Duration(seconds: 4),
    content: Row(children: [
      Icon(icon, color: color ?? t.textPrimary, size: 22),
      const SizedBox(width: 12),
      Expanded(
          child: Text(message,
              style: TextStyle(color: t.textPrimary, fontSize: 15, fontWeight: FontWeight.w500))),
    ]),
    action: action,
  ));
}
