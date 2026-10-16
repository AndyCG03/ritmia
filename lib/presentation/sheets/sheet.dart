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
