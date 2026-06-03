import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;

  const StatusBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (text.toLowerCase()) {
      case 'present':
      case 'active':
      case 'online':
      case 'live':
        textColor = AppColors.success;
        bgColor = AppColors.success.withAlpha(25);
        break;
      case 'late':
      case 'on leave':
      case 'warning':
        textColor = AppColors.warning;
        bgColor = AppColors.warning.withAlpha(25);
        break;
      case 'absent':
      case 'inactive':
      case 'offline':
      case 'critical':
        textColor = AppColors.error;
        bgColor = AppColors.error.withAlpha(25);
        break;
      case 'medium':
      case 'high':
        textColor = AppColors.warning;
        bgColor = AppColors.warning.withAlpha(25);
        break;
      default:
        textColor = AppColors.primary;
        bgColor = AppColors.primary.withAlpha(25);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
