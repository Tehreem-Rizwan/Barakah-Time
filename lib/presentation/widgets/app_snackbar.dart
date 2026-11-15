import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

enum SnackType { info, success, error, warning }

extension on SnackType {
  Color get color => switch (this) {
    SnackType.info => AppColors.secondaryGold,
    SnackType.success => AppColors.success,
    SnackType.error => AppColors.error,
    SnackType.warning => AppColors.warning,
  };

  IconData get icon => switch (this) {
    SnackType.info => Icons.info_outline_rounded,
    SnackType.success => Icons.check_circle_outline_rounded,
    SnackType.error => Icons.error_outline_rounded,
    SnackType.warning => Icons.warning_amber_rounded,
  };
}

/// Shows a floating, themed snack bar (replacing any current one).
///
/// Replaces ad-hoc `SnackBar(backgroundColor: Colors.redAccent, ...)`:
/// `showAppSnackBar(context, msg, type: SnackType.error)`.
/// No-op if there is no [ScaffoldMessenger].
void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackType type = SnackType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = AppDurations.snackBar,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final color = type.color;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        content: Row(
          children: [
            Icon(type.icon, color: color, size: 22.sp),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
}
