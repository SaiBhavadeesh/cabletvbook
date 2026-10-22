import 'package:flutter/material.dart';
import 'package:cableTvBook/theme/app_colors.dart';

BoxDecoration defaultBoxDecoration(BuildContext context, bool shadow) {
  return BoxDecoration(
    boxShadow: shadow ? AppColors.floatingShadow : null,
    borderRadius: BorderRadius.circular(16),
    gradient: AppColors.primaryGradient,
  );
}

BoxDecoration pageDecoration(BuildContext context) {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF18181B),
        Color(0xFF27272A),
        Color(0xFF78350F),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

BoxDecoration sweepGradientDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: const SweepGradient(
      colors: [
        AppColors.primary,
        AppColors.accent,
        AppColors.primaryLight,
      ],
    ),
  );
}

InputDecoration inputDecoration({
  String? label,
  String? prefixText,
  IconData? icon,
  Color? filledColor,
  bool filled = true,
  String? hint,
  Color? iconColor,
  Color hintColor = AppColors.textMuted,
  double radius = 12,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    counter: const SizedBox.shrink(),
    fillColor: filledColor ?? Colors.white,
    filled: filled,
    hintText: hint,
    hintStyle: TextStyle(
      color: hintColor,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    labelText: label,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    prefixText: prefixText,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}
