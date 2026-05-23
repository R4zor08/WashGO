import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  /// Use on blue gradient hero cards for high-contrast readable text.
  final bool onGradient;

  const StatusBadge({
    super.key,
    required this.status,
    this.onGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.statusColor(status);

    if (onGradient) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.midnightBlue.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          status,
          style: AppTextStyles.badge.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: AppTextStyles.badge.copyWith(color: accent),
      ),
    );
  }
}
