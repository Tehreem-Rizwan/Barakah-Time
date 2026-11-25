import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/daily_challenges.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../injection_container.dart';
import '../widgets/widgets.dart';

/// Today's three challenges (Pulse page). They complete themselves from the
/// activities the app already logs; a day with all three done is recorded
/// as a "perfect day".
class ChallengesCard extends StatefulWidget {
  const ChallengesCard({super.key, required this.today, this.clock});

  /// Activities logged today.
  final List<SpiritualActivity> today;
  final DateTime Function()? clock;

  @override
  State<ChallengesCard> createState() => _ChallengesCardState();
}

class _ChallengesCardState extends State<ChallengesCard> {
  PerfectDays? _perfect;

  @override
  void initState() {
    super.initState();
    if (sl.isRegistered<SharedPreferences>()) {
      _perfect = PerfectDays(sl<SharedPreferences>());
    }
  }

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final statuses = DailyChallenges.evaluate(widget.today);
    final allDone = DailyChallenges.allDone(statuses);
    final perfect = _perfect;
    if (allDone && perfect != null && !perfect.contains(_now)) {
      // Record after this frame, then show the updated weekly count.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await perfect.mark(_now);
        if (mounted) setState(() {});
      });
    }

    (IconData, String) describe(ChallengeKind k) => switch (k) {
      ChallengeKind.prayers => (Icons.mosque_outlined, l10n.challenge_prayers),
      ChallengeKind.quran => (Icons.menu_book_outlined, l10n.challenge_quran),
      ChallengeKind.dhikr => (
        Icons.blur_circular_outlined,
        l10n.challenge_dhikr,
      ),
    };

    return AppCard(
      border: Border.all(
        color: (allDone ? AppColors.success : AppColors.secondaryGold)
            .withValues(alpha: 0.45),
      ),
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: AppColors.secondaryGold,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.daily_challenges,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${statuses.where((s) => s.done).length}/${statuses.length}',
                textDirection: TextDirection.ltr,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            l10n.challenges_hint,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          for (final s in statuses)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Icon(
                    describe(s.kind).$1,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      describe(s.kind).$2,
                      style: textTheme.bodyMedium?.copyWith(
                        decoration: s.done ? TextDecoration.lineThrough : null,
                        color: s.done ? AppColors.textSecondary : null,
                      ),
                    ),
                  ),
                  if (s.goal > 1 && !s.done)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 6.w),
                      child: Text(
                        '${s.progress}/${s.goal}',
                        textDirection: TextDirection.ltr,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  Icon(
                    s.done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22.sp,
                    color: s.done ? AppColors.success : AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          if (allDone) ...[
            SizedBox(height: AppSpacing.vSm),
            Text(
              '✨ ${l10n.challenges_all_done}',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (perfect != null) ...[
            Divider(height: AppSpacing.vLg),
            Text(
              l10n.perfectDaysWeek(perfect.inLastWeek(_now)),
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
