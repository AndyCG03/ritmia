import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../domain/repositories.dart';
import '../l10n/context.dart';
String errorMessage(BuildContext context,Object error) {
  final s = context.l10n;
  final code = switch(error) {
    AppFailure(:final code) => code,
    FirebaseFunctionsException(:final code) => code,
    FirebaseAuthException(:final code) => code,
    _ => 'unknown',
  };
  return switch(code) {
    'limit' || 'resource-exhausted' => s.limitMessage,
    'aborted' || 'conflict' => s.conflictMessage,
    'image' => s.imageError,
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
void showFailure(BuildContext context,Object error) => ScaffoldMessenger.of(context)
  .showSnackBar(SnackBar(content:Text(errorMessage(context,error))));
