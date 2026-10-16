import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';

/// Opens a Ritmia bottom sheet: 24 px top corners, drag handle, gentle scrim.
/// [heightFactor] fixes the height for list-style sheets; null sizes to content.
Future<T?> showRitmiaSheet<T>(BuildContext context, {required WidgetBuilder builder, double? heightFactor, double maxFactor = 0.86}) {
  return showModalBottomSheet<T>(
    context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
    constraints: BoxConstraints(maxWidth: 640, maxHeight: MediaQuery.sizeOf(context).height * maxFactor),
    builder: (context) {
      final content = Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: builder(context));
      return heightFactor == null ? content
        : SizedBox(height: MediaQuery.sizeOf(context).height * heightFactor, child: content);
    });
}

/// Close "X" used at the top-right of every sheet (48 px target).
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.close, onPressed: () => Navigator.maybePop(context),
    icon: Icon(Icons.close_rounded, color: context.tokens.textPrimary, size: 26));
}

/// Hairline separator in the current theme.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});
  final double indent;
  @override
  Widget build(BuildContext context) => Divider(height: 1, thickness: 1, indent: indent, color: context.tokens.separator);
}

/// Calm confirmation sheet: icon tile, title, explanation, primary action and a quiet cancel.
/// Destructive actions use the muted coral and never look like the default choice.
Future<bool> showConfirmSheet(BuildContext context, {required IconData icon, required String title,
    required String body, required String confirmLabel, bool destructive = false}) async {
  final result = await showRitmiaSheet<bool>(context, builder: (c) {
    final t = c.tokens;
    final tone = destructive ? t.danger : t.textAction;
    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Align(alignment: Alignment.centerLeft, child: Container(width: 52, height: 52,
        decoration: BoxDecoration(color: tone.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: tone, size: 26))),
      const SizedBox(height: 18),
      Semantics(header: true, child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: t.textPrimary))),
      const SizedBox(height: 8),
      Text(body, style: TextStyle(fontSize: 16, height: 1.45, color: t.textSecondary)),
      const SizedBox(height: 28),
      FilledButton(onPressed: () => Navigator.pop(c, true),
        style: destructive ? FilledButton.styleFrom(backgroundColor: t.danger, foregroundColor: Theme.of(c).brightness == Brightness.dark ? BrandTheme.ink : Colors.white) : null,
        child: Text(confirmLabel)),
      const SizedBox(height: 4),
      TextButton(onPressed: () => Navigator.pop(c, false), style: TextButton.styleFrom(foregroundColor: t.textPrimary),
        child: Text(c.l10n.cancel)),
    ]));
  });
  return result == true;
}
