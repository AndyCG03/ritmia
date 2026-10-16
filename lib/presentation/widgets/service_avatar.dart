import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/catalog.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../domain/subscription.dart';
import 'generic_icons.dart';

/// Very dark brand colors read as "ink" and follow the text color, so they stay visible in dark mode.
Color brandInk(BuildContext context, int color) {
  final c = Color(color);
  return c.computeLuminance() < 0.05 ? context.tokens.textPrimary : c;
}

/// Neutral square tile with a service mark: uploaded logo, catalog SVG or a typographic fallback.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.name, this.brand, this.bytes, this.icon, this.size = 52});
  final String name;
  final ServiceBrand? brand;
  final dynamic bytes;
  /// Generic icon for custom services.
  final IconData? icon;
  final double size;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tint = brandInk(context, brand?.color ?? BrandTheme.ink.toARGB32());
    final inner = size * 0.52;
    Widget child;
    if (bytes != null) {
      child = ClipRRect(borderRadius: BorderRadius.circular(size * 0.16),
        child: Image.memory(bytes, width: inner + 6, height: inner + 6, fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(Icons.image_not_supported_outlined, color: t.textSecondary)));
    } else if (icon != null) {
      child = Icon(icon, size: inner, color: t.textPrimary);
    } else if (brand != null && brand!.hasAsset) {
      child = SvgPicture.asset(brand!.asset, width: inner, height: inner,
        colorFilter: brand!.preserveColors ? null : ColorFilter.mode(tint, BlendMode.srcIn));
    } else {
      child = Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(color: t.textPrimary, fontSize: size * 0.42, fontWeight: FontWeight.w600, height: 1));
    }
    return ExcludeSemantics(child: Container(width: size, height: size, alignment: Alignment.center,
      decoration: BoxDecoration(color: t.tile, borderRadius: BorderRadius.circular(size * 0.25)), child: child));
  }
}

class ServiceAvatar extends ConsumerWidget {
  const ServiceAvatar({super.key, required this.item, this.size = 52});
  final Subscription item;
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logo = ref.watch(logoProvider(item)).asData?.value;
    return BrandMark(name: item.name, brand: findBrand(item.brandId), icon: genericIconFor(item.brandId), bytes: logo, size: size);
  }
}
