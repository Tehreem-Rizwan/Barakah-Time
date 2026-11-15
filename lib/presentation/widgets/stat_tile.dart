import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_card.dart';

/// Compact metric card: optional icon, big value, small label.
/// Read by screen readers as "value, label".
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.onTap,
    this.valueColor,
  });

  final String value;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  /// Defaults to [AppColors.secondaryGold].
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$value, $label',
      container: true,
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.vLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.secondaryGold, size: 22.sp),
              SizedBox(height: AppSpacing.vSm),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.secondaryGold,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays out [children] (typically [StatTile]s) in a row of equal-width,
/// equal-height cells separated by [AppSpacing.md].
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.children, this.spacing});

  final List<Widget> children;

  /// Gap between cells; defaults to [AppSpacing.md].
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? AppSpacing.md;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}
