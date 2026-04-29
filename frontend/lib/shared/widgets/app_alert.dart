import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppAlertVariant { info, success, error }

class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.message,
    this.title,
    this.variant = AppAlertVariant.info,
  });

  final String? title;
  final String message;
  final AppAlertVariant variant;

  Color get _backgroundColor {
    return switch (variant) {
      AppAlertVariant.info => AppColors.infoBackground,
      AppAlertVariant.success => AppColors.successBackground,
      AppAlertVariant.error => AppColors.errorBackground,
    };
  }

  Color get _foregroundColor {
    return switch (variant) {
      AppAlertVariant.info => AppColors.secondary,
      AppAlertVariant.success => AppColors.success,
      AppAlertVariant.error => AppColors.error,
    };
  }

  IconData get _icon {
    return switch (variant) {
      AppAlertVariant.info => Icons.info_outline,
      AppAlertVariant.success => Icons.check_circle_outline,
      AppAlertVariant.error => Icons.error_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _foregroundColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.body.copyWith(
                      color: _foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
