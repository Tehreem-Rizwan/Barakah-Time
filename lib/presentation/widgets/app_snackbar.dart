import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

enum SnackType { info, success, error, warning }

extension on SnackType {
  /// Icon colours chosen for the dark-ink snackbar background.
  Color get color => switch (this) {
    SnackType.info => AppColors.infoOnDark,
    SnackType.success => AppColors.successOnDark,
    SnackType.error => AppColors.errorOnDark,
    SnackType.warning => AppColors.brass,
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
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        content: Row(
          children: [
            Icon(type.icon, color: color, size: 22.sp),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
        action:
            actionLabel != null && onAction != null
                ? SnackBarAction(label: actionLabel, onPressed: onAction)
                : null,
      ),
    );
}
