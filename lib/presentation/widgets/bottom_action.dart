import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared footer spacing, including the phone's gesture/navigation inset even inside modal sheets.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.paddingOf(context).bottom, MediaQuery.viewPaddingOf(context).bottom);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + bottom),
      child: SizedBox(width: double.infinity, height: 56, child: child),
    );
  }
}
