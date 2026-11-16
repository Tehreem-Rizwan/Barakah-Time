import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_card.dart';

/// "Our promise": no ads, no data selling, no trackers. Keep this true —
/// the app ships no ad or analytics SDKs.
class PrivacyPromiseCard extends StatelessWidget {
  const PrivacyPromiseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final points = [
      (Icons.block_rounded, l10n.translate('promise_no_ads')),
      (Icons.lock_outline_rounded, l10n.translate('promise_no_sell')),
      (Icons.visibility_off_outlined, l10n.translate('promise_no_tracking')),
      (Icons.location_on_outlined, l10n.translate('promise_location')),
    ];
    return AppCard(
      padding: AppSpacing.card,
      border: Border.all(
        color: AppColors.secondaryGold.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.secondaryGold,
                size: 22.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                l10n.translate('promise_title'),
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryGold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          for (final (icon, text) in points)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18.sp, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(text, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
