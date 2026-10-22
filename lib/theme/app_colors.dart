import 'package:flutter/material.dart';

/// Classy, executive warm bronze & obsidian gold color palette for Cable TV Book.
/// Inspired by the gold operator medallion aesthetic — elegant, dignified, and premium.
class AppColors {
  AppColors._();

  // Brand Primaries (Classy Burnished Bronze & Regal Gold)
  static const Color primary = Color(0xFFB45309); // Warm Burnished Bronze
  static const Color primaryLight = Color(0xFFD97706); // Rich Gold Amber
  static const Color primaryDark = Color(0xFF78350F); // Deep Cognac Espresso
  static const Color primaryContainer = Color(0xFFFEF3C7); // Champagne Gold Tint
  static const Color secondary = Color(0xFFD97706); // Amber Gold
  static const Color champagne = Color(0xFFFEF3C7); // Champagne Gold
  static const Color canvasDark = Color(0xFF18181B); // Obsidian Slate Canvas

  // Brand Accents (Gilded Champagne & Warm Brass)
  static const Color accent = Color(0xFFCA8A04); // Warm Brass Gold
  static const Color accentContainer = Color(0xFFFEF9C3); // Soft Sunlight Gold

  // Surfaces & Backgrounds (Warm Alabaster & Warm Stone)
  static const Color background = Color(0xFFFAF9F6); // Warm Alabaster Stone
  static const Color surface = Color(0xFFFFFFFF); // Crisp Pure White
  static const Color surfaceVariant = Color(0xFFF5F5F4); // Stone 100
  static const Color cardBorder = Color(0xFFE7E5E4); // Stone 200 Warm Border

  // Typography (Rich Espresso Slate & Warm Neutral)
  static const Color textPrimary = Color(0xFF1C1917); // Stone 900 Espresso
  static const Color textSecondary = Color(0xFF57534E); // Stone 600 Warm Slate
  static const Color textMuted = Color(0xFFA8A29E); // Stone 400
  static const Color textOnPrimary = Colors.white;

  // Semantics & Statuses
  static const Color success = Color(0xFF15803D); // Deep Forest Emerald
  static const Color successLight = Color(0xFFF0FDF4); // Emerald 50
  static const Color successDark = Color(0xFF14532D);

  static const Color warning = Color(0xFFD97706); // Warm Amber
  static const Color warningLight = Color(0xFFFFFBEB); // Amber 50
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFDC2626); // Rich Crimson
  static const Color errorLight = Color(0xFFFEF2F2); // Rose 50
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFFB45309); // Burnished Gold
  static const Color infoLight = Color(0xFFFEF3C7);

  // Luxury Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldMedallionGradient = LinearGradient(
    colors: [Color(0xFF92400E), Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFDE68A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF18181B), Color(0xFF27272A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFFCA8A04)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAF9F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Soft warm shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: const Color(0xFF78350F).withValues(alpha: 0.20),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}
