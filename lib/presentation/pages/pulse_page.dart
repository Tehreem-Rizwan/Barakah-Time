import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_labels.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../domain/entities/spiritual_pulse.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';

/// Points needed on a day for it to count as "active" in the charts.
const int kActiveDayPoints = 50;

/// Sum of the last 7 days' points.
int weeklyPointsOf(SpiritualPulseEntity pulse) =>
    pulse.dailyPoints.fold<int>(0, (s, p) => s + p);

/// Reloads pulse data; completes when loaded (or after a short timeout,
/// since unchanged data emits nothing).
Future<void> refreshPulse(BuildContext context) async {
  final bloc = context.read<PulseBloc>();
  final done = bloc.stream
      .firstWhere((s) => s is! PulseLoading)
      .timeout(const Duration(seconds: 3), onTimeout: () => bloc.state);
  bloc.add(LoadPulseData());
  await done;
}

/// Localized title for an activity log entry.
String activityTitle(AppLocalizations l10n, SpiritualActivity activity) {
  switch (activity.type) {
    case 'prayer':
      final sub = activity.subType;
      final prayer = sub == null ? '' : l10n.translate(sub);
      return l10n.activity_prayer.replaceAll('{prayer}', prayer).trim();
    case 'quran':
      return l10n.activity_quran;
    case 'dhikr':
      return l10n.activity_dhikr;
    default:
      return l10n.activity_other;
  }
}

IconData _activityIcon(String type) => switch (type) {
  'prayer' => Icons.mosque_outlined,
  'quran' => Icons.menu_book_outlined,
  'dhikr' => Icons.blur_circular_outlined,
  _ => Icons.bolt_outlined,
};

IconData _badgeIcon(String id) => switch (id) {
  BadgeIds.firstStep => Icons.flag_outlined,
  BadgeIds.streak7 ||
  BadgeIds.streak30 ||
  BadgeIds.streak100 => Icons.local_fire_department_outlined,
  BadgeIds.dailyAchiever => Icons.emoji_events_outlined,
  BadgeIds.spiritualVeteran => Icons.workspace_premium_outlined,
  BadgeIds.points1000 => Icons.stars_outlined,
  _ => Icons.military_tech_outlined,
};

class PulsePage extends StatelessWidget {
  const PulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.pulse,
      body: BlocConsumer<PulseBloc, PulseState>(
        listenWhen:
            (p, c) =>
                c is PulseLoaded &&
                c.error != null &&
                (p is! PulseLoaded || p.error != c.error),
        listener: (context, state) {
          showAppSnackBar(
            context,
            context.l10n.pulse_load_failed,
            type: SnackType.error,
          );
        },
        builder: (context, state) {
          final Widget child;
          if (state is PulseLoaded) {
            child = _PulseContent(pulse: state.pulse);
          } else if (state is PulseLoading) {
            child = const StateView.loading();
          } else {
            child = StateView.error(
              message:
                  state is PulseError ? l10n.pulse_load_failed : l10n.no_data,
              onRetry: () => context.read<PulseBloc>().add(LoadPulseData()),
            );
          }
          return RefreshIndicator(
            onRefresh: () => refreshPulse(context),
            child: child,
          );
        },
      ),
    );
  }
}

class _PulseContent extends StatelessWidget {
  const _PulseContent({required this.pulse});

  final SpiritualPulseEntity pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final gap = SizedBox(height: AppSpacing.vXl);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.page,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: l10n.spiritual_insight,
                icon: Icons.auto_awesome,
              ),
              SizedBox(height: AppSpacing.vMd),
              Text(
                l10n.translate(pulse.motivation.l10nKey),
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.vLg),
        StatRow(
          children: [
            StatTile(
              value: '${weeklyPointsOf(pulse)}',
              label: l10n.points_this_week,
              icon: Icons.bolt_outlined,
            ),
            StatTile(
              value: '${pulse.totalPoints}',
              label: l10n.lifetime_points,
              icon: Icons.stars_outlined,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.vMd),
        StatRow(
          children: [
            StatTile(
              value: '${pulse.currentStreak}',
              label: l10n.current_streak,
              icon: Icons.local_fire_department_outlined,
            ),
            StatTile(
              value: '${pulse.longestStreak}',
              label: l10n.longest_streak,
              icon: Icons.emoji_events_outlined,
            ),
          ],
        ),
        gap,
        _StreakCard(streak: pulse.currentStreak),
        gap,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: l10n.weekly_activity,
                icon: Icons.bar_chart_rounded,
              ),
              SizedBox(height: AppSpacing.vLg),
              WeeklyBars(points: pulse.dailyPoints, showValues: true),
            ],
          ),
        ),
        gap,
        _BadgesSection(badges: pulse.badges),
        gap,
        _RecentActivitySection(activities: pulse.recentActivities),
        SizedBox(height: AppSpacing.vLg),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final nextMilestone = ((streak ~/ 7) + 1) * 7;
    return AppCard(
      blur: true,
      color: AppColors.secondaryGold,
      border: Border.all(
        color: AppColors.secondaryGold.withValues(alpha: 0.45),
        width: 1.5,
      ),
      padding: AppSpacing.all(20),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryGold.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.secondaryGold.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.secondaryGold,
              size: 30.sp,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.day_streak_count.replaceAll('{n}', '$streak'),
                  style: textTheme.titleLarge,
                ),
                SizedBox(height: AppSpacing.vXs),
                Text(
                  '${l10n.milestone} $nextMilestone ${l10n.days}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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

/// Seven-day bar chart (oldest first, ending today) with localized weekday
/// labels and one semantics label per bar.
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({
    super.key,
    required this.points,
    this.showValues = false,
    this.barHeight,
    this.now,
  });

  /// Daily points for the last 7 days (oldest first).
  final List<int> points;

  /// Show each day's points above its bar.
  final bool showValues;

  /// Height of the bar track; defaults to 110.h.
  final double? barHeight;

  /// Injectable "today" for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final today = now ?? DateTime.now();
    final count = points.length;
    final short = lastDaysWeekdayLabels(locale, count: count, now: today);
    DateFormat longFormat;
    try {
      longFormat = DateFormat('EEEE', locale);
    } catch (_) {
      longFormat = DateFormat('EEEE', 'en');
    }
    final maxValue = points.fold<int>(100, (m, p) => p > m ? p : m);
    final trackHeight = barHeight ?? 110.h;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: Semantics(
              label: l10n.weekday_points
                  .replaceAll(
                    '{day}',
                    longFormat.format(
                      DateTime(
                        today.year,
                        today.month,
                        today.day - (count - 1 - i),
                      ),
                    ),
                  )
                  .replaceAll('{n}', '${points[i]}'),
              container: true,
              excludeSemantics: true,
              child: Column(
                children: [
                  if (showValues)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${points[i]}',
                        maxLines: 1,
                        style: textTheme.labelSmall?.copyWith(
                          color:
                              points[i] >= kActiveDayPoints
                                  ? AppColors.secondaryGold
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (showValues) SizedBox(height: AppSpacing.vXs),
                  Container(
                    width: 24.w,
                    height: trackHeight,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: AppColors.glassBase,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: AnimatedFractionallySizedBox(
                      duration: AppDurations.slow,
                      curve: AppDurations.curve,
                      heightFactor: (points[i] / maxValue).clamp(0.06, 1.0),
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.pillAll,
                          color:
                              points[i] >= kActiveDayPoints
                                  ? AppColors.secondaryGold
                                  : AppColors.secondaryGold.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.vSm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      short[i],
                      maxLines: 1,
                      style: textTheme.labelSmall?.copyWith(
                        color:
                            i == count - 1
                                ? AppColors.secondaryGold
                                : AppColors.textSecondary,
                        fontWeight:
                            i == count - 1 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.badges, icon: Icons.military_tech_outlined),
        SizedBox(height: AppSpacing.vMd),
        if (badges.isEmpty)
          AppCard(
            child: Text(
              l10n.no_badges_yet,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          Text(
            l10n
                .translate('badges_earned')
                .replaceAll('{n}', '${badges.length}'),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.vSm,
            children: [
              for (final id in badges)
                Tooltip(
                  message: l10n.translate(badgeDescriptionL10nKey(id)),
                  child: AppCard(
                    borderRadius: AppRadius.pillAll,
                    color: AppColors.secondaryGold,
                    padding: AppSpacing.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _badgeIcon(id),
                          size: 18.sp,
                          color: AppColors.secondaryGold,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            l10n.translate(badgeL10nKey(id)),
                            style: textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.activities});

  final List<SpiritualActivity> activities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    DateFormat format;
    try {
      format = DateFormat.MMMEd(locale).add_jm();
    } catch (_) {
      format = DateFormat.MMMEd('en').add_jm();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.recent_activity, icon: Icons.history),
        SizedBox(height: AppSpacing.vMd),
        if (activities.isEmpty)
          AppCard(
            child: Text(
              l10n.no_recent_activity,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < activities.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ActionTile(
                    icon: _activityIcon(activities[i].type),
                    title: activityTitle(l10n, activities[i]),
                    subtitle: format.format(activities[i].timestamp),
                    trailing: Text(
                      l10n.points_gained.replaceAll(
                        '{n}',
                        '${activities[i].points}',
                      ),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.secondaryGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
