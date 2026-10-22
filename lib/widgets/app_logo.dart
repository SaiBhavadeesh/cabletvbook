import 'package:flutter/material.dart';

/// Classy, minimalist brand logo for Cable TV Book.
/// Renders the embossed gold cable technician with coiled cable on shoulder
/// and antenna TV monitor with radiating waves — completely text-free.
class AppLogo extends StatelessWidget {
  final double size;
  final bool hasShadow;
  final double borderRadius;
  final bool showBadge;

  const AppLogo({
    super.key,
    this.size = 64,
    this.hasShadow = true,
    this.borderRadius = 16,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius * (size / 64.0)),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

    if (!hasShadow) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius * (size / 64.0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.25),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
          BoxShadow(
            color: const Color(0xFF18181B).withValues(alpha: 0.15),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      child: image,
    );
  }
}
