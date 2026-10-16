import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Semantic color tokens for Ritmia. Views read these instead of raw hex values.
@immutable
class RitmiaTokens extends ThemeExtension<RitmiaTokens> {
  const RitmiaTokens({
    required this.background, required this.sheet, required this.tile,
    required this.field, required this.textPrimary, required this.textSecondary,
    required this.separator, required this.accent, required this.onAccent,
    required this.textAction, required this.danger, required this.selectedDay,
    required this.onSelectedDay, required this.dotToday, required this.dotOther,
    required this.scrim,
  });
  final Color background, sheet, tile, field, textPrimary, textSecondary, separator,
    accent, onAccent, textAction, danger, selectedDay, onSelectedDay, dotToday, dotOther, scrim;

  static const light = RitmiaTokens(
    background: BrandTheme.paper, sheet: BrandTheme.paper, tile: Color(0xFFEFEBE4),
    field: Color(0xFFF0EDE7), textPrimary: BrandTheme.ink, textSecondary: Color(0xFF6B6577),
    separator: Color(0xFFE3DED5), accent: BrandTheme.lavender, onAccent: BrandTheme.ink,
    textAction: Color(0xFF7251AF), danger: Color(0xFFB0473A), selectedDay: BrandTheme.ink,
    onSelectedDay: Colors.white, dotToday: BrandTheme.coral, dotOther: BrandTheme.lavender,
    scrim: Color(0x66282338),
  );
  static const dark = RitmiaTokens(
    background: Color(0xFF121116), sheet: Color(0xFF1D1A24), tile: Color(0xFF2A2633),
    field: Color(0xFF26222E), textPrimary: Color(0xFFF2EEF7), textSecondary: Color(0xFFAAA5B5),
    separator: Color(0xFF34303F), accent: BrandTheme.lavender, onAccent: BrandTheme.ink,
    textAction: BrandTheme.lavender, danger: BrandTheme.coral, selectedDay: BrandTheme.lavender,
    onSelectedDay: BrandTheme.ink, dotToday: BrandTheme.coral, dotOther: BrandTheme.lavender,
    scrim: Color(0x99000000),
  );

  @override
  RitmiaTokens copyWith() => this;
  @override
  RitmiaTokens lerp(ThemeExtension<RitmiaTokens>? other, double t) => t < 0.5 ? this : (other as RitmiaTokens? ?? this);
}

extension RitmiaTokensContext on BuildContext {
  RitmiaTokens get tokens => Theme.of(this).extension<RitmiaTokens>()!;
}

abstract final class BrandTheme {
  static const ink = Color(0xFF282338), lavender = Color(0xFFB9A3F5),
    coral = Color(0xFFF47D68), paper = Color(0xFFF8F6F1);
  static const colors = [0xFF7756B8,0xFFBC4635,0xFF24735E,0xFF285FAD,0xFF9A5F16,0xFFBD3979,0xFF282338];
  static const tabular = [FontFeature.tabularFigures()];

  static ThemeData get light => _build(Brightness.light, RitmiaTokens.light);
  static ThemeData get dark => _build(Brightness.dark, RitmiaTokens.dark);

  static ThemeData _build(Brightness brightness, RitmiaTokens t) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF7251AF), brightness: brightness).copyWith(
      surface: t.background, onSurface: t.textPrimary, onSurfaceVariant: t.textSecondary,
      primary: t.textAction, onPrimary: brightness == Brightness.dark ? ink : Colors.white,
      outline: t.separator, outlineVariant: t.separator, error: t.danger,
      surfaceContainerLow: t.sheet, surfaceContainerHighest: t.tile);
    final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: t.background,
      extensions: [t],
      textTheme: base.textTheme.apply(bodyColor: t.textPrimary, displayColor: t.textPrimary),
      dividerTheme: DividerThemeData(color: t.separator, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(backgroundColor: t.background, foregroundColor: t.textPrimary,
        centerTitle: false, elevation: 0, scrolledUnderElevation: 0,
        systemOverlayStyle: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: t.sheet, modalBackgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent, modalBarrierColor: t.scrim,
        dragHandleColor: t.textSecondary.withValues(alpha: 0.5), dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: t.field,
        hintStyle: TextStyle(color: t.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.separator)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.separator)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.textAction, width: 1.5))),
      cardTheme: CardThemeData(elevation: 0, color: t.tile, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: t.accent, foregroundColor: t.onAccent, minimumSize: const Size(48, 56),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: t.textPrimary, minimumSize: const Size(48, 56), side: BorderSide(color: t.textPrimary.withValues(alpha: 0.7)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: t.textAction,
        minimumSize: const Size(48, 48), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      iconTheme: IconThemeData(color: t.textPrimary),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
