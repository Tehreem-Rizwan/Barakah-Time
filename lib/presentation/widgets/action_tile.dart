import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// A settings / profile row: tinted icon badge, title, optional subtitle and
/// trailing widget.
///
/// When [onTap] is set and no [trailing] is given, a chevron is shown; it
/// flips automatically in RTL. [destructive] colors the icon and title with
/// [AppColors.error] (e.g. "Delete account", "Sign out").
///
/// Place several tiles inside an `AppCard(padding: EdgeInsets.zero, ...)`
/// separated by `Divider(indent: ...)` to form a grouped list.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.error : AppColors.secondaryGold;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        minTileHeight: 56.h,
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
        ),
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(icon, color: accent, size: 20.sp),
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontSize: 15.sp,
            color: destructive ? AppColors.error : AppColors.textMain,
          ),
        ),
        subtitle:
            subtitle == null
                ? null
                : Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                )
                : null),
      ),
    );
  }
}
