import 'package:flutter/material.dart';
import 'package:cableTvBook/theme/app_colors.dart';

Widget defaultbutton({
  required BuildContext context,
  required VoidCallback function,
  required String title,
  IconData? icon,
  double width = 45,
  double height = 16,
  bool fullWidth = false,
  bool isLoading = false,
}) {
  final buttonContent = Row(
    mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      if (isLoading)
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      else if (icon != null) ...[
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
      ],
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    ],
  );

  return Container(
    width: fullWidth ? double.infinity : null,
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: AppColors.floatingShadow,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : function,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > 0 ? width : 24,
            vertical: height > 0 ? height : 14,
          ),
          child: buttonContent,
        ),
      ),
    ),
  );
}
