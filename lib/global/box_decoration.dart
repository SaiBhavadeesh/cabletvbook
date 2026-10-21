import 'package:flutter/material.dart';

BoxDecoration defaultBoxDecoration(BuildContext context, bool shadow) {
  final primary = Theme.of(context).primaryColor;
  return BoxDecoration(
    boxShadow: shadow
        ? [
            const BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 3,
            ),
          ]
        : null,
    borderRadius: BorderRadius.circular(30),
    gradient: LinearGradient(
      colors: [
        primary.withAlpha(200),
        primary.withAlpha(230),
        primary,
      ],
    ),
  );
}

BoxDecoration pageDecoration(BuildContext context) {
  final primary = Theme.of(context).primaryColor;
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        primary.withAlpha(190),
        primary.withAlpha(220),
        primary,
        primary.withAlpha(220),
        primary.withAlpha(190),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

BoxDecoration sweepGradientDecoration(BuildContext context) {
  final primary = Theme.of(context).primaryColor;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: SweepGradient(colors: [
      primary,
      primary.withAlpha(128),
      primary.withAlpha(178),
    ]),
  );
}

InputDecoration inputDecoration({
  String? label,
  String? prefixText,
  IconData? icon,
  Color? filledColor,
  bool filled = false,
  String? hint,
  Color? iconColor,
  Color hintColor = Colors.black,
  double radius = 15,
}) {
  return InputDecoration(
    counter: const SizedBox.shrink(),
    fillColor: filledColor,
    filled: filled,
    hintText: hint,
    hintStyle: TextStyle(color: hintColor),
    focusedBorder: filled
        ? OutlineInputBorder(borderRadius: BorderRadius.circular(15))
        : null,
    labelText: label,
    contentPadding: const EdgeInsets.all(8),
    prefixText: prefixText,
    prefixIcon: icon == null ? null : Icon(icon, color: iconColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
