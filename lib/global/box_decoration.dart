import 'package:flutter/material.dart';

BoxDecoration defaultBoxDecoration(BuildContext context, bool shadow) {
  return BoxDecoration(
    boxShadow: shadow
        ? [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 3,
            ),
          ]
        : null,
    borderRadius: BorderRadius.circular(30),
    gradient: LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withRed(200),
        Theme.of(context).primaryColor.withRed(400),
        Theme.of(context).primaryColor.withRed(600),
      ],
    ),
  );
}

BoxDecoration pageDecoration(BuildContext context) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withBlue(150).withOpacity(0.75),
        Theme.of(context).primaryColor.withOpacity(0.75),
        Theme.of(context).primaryColor.withBlue(255).withOpacity(0.75),
        Theme.of(context).primaryColor.withOpacity(0.75),
        Theme.of(context).primaryColor.withBlue(150).withOpacity(0.75),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

BoxDecoration sweepGradientDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: SweepGradient(colors: [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.withOpacity(0.5),
      Theme.of(context).primaryColor.withOpacity(0.7),
    ]),
  );
}

InputDecoration inputDecoration(
    {String label,
    String prefixText,
    IconData icon,
    Color filledColor,
    bool filled = false,
    String hint,
    Color iconColor,
    Color hintColor = Colors.black,
    double radius = 15}) {
  return InputDecoration(
    counter: SizedBox(),
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
