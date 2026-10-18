import 'package:flutter/material.dart';

/// The original AI-generated PNG is the single source of the Ritmia mark.
class RitmiaLogo extends StatelessWidget {
  const RitmiaLogo({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .24),
    child: Image.asset('assets/brand/app-icon-ai.png', width: size, height: size,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
      semanticLabel: 'Ritmia', fit: BoxFit.cover));
}
