import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  _ => Icons.auto_graph_outlined,
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

/// Eight-pointed star (two overlapping squares) filling [size], point up.
Path _starPath(Size size, double inset) {
  final c = Offset(size.width / 2, size.height / 2);
  final r = size.shortestSide / 2 - inset;
  final path = Path();
  for (final start in [0.0, math.pi / 4]) {
    for (var i = 0; i < 4; i++) {
      final a = start + i * math.pi / 2 - math.pi / 2;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
  }
  return path;
}

class PulsePage extends StatelessWidget {
  const PulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnBand,
      child: AppScaffold(
        safeAreaTop: false,
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
              child = _PulseContent(state: state);
            } else if (state is PulseLoading) {
              child = const StateView.loading();
            } else {
              child = SafeArea(
                child: StateView.error(
                  message:
                      state is PulseError
                          ? l10n.pulse_load_failed
                          : l10n.no_data,
                  onRetry: () => context.read<PulseBloc>().add(LoadPulseData()),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => refreshPulse(context),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _PulseContent extends StatelessWidget {
  const _PulseContent({required this.state});

  final PulseLoaded state;

  @override
  Widget build(BuildContext context) {
    final pulse = state.pulse;
    final gap = SizedBox(height: AppSpacing.vLg);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _PulseHeader(pulse: pulse),
        Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TodayPrayersCard(state: state),
              gap,
              _StreakCard(pulse: pulse),
              gap,
              _WeekCard(pulse: pulse),
              SizedBox(height: AppSpacing.vXl),
              _BadgesSection(badges: pulse.badges),
              SizedBox(height: AppSpacing.vXl),
              _RecentActivitySection(activities: pulse.recentActivities),
              gap,
            ],
          ),
        ),
      ],
    );
  }
}

/// Turquoise tile band with today's progress drawn as an eight-pointed star
/// that fills with brass as the day's points grow toward 100.
class _PulseHeader extends StatelessWidget {
  const _PulseHeader({required this.pulse});

  final SpiritualPulseEntity pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final today = pulse.dailyPoints.isEmpty ? 0 : pulse.dailyPoints.last;
    final progress = (today / 100).clamp(0.0, 1.0);
    return Stack(
      children: [
        Positioned.fill(child: IslamicHeaderBand(height: top + 320.h)),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            top + AppSpacing.vLg,
            AppSpacing.xl,
            AppSpacing.vXl,
          ),
          child: Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.pulse,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.ivoryOnTeal,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vLg),
              Semantics(
                label: '${l10n.translate('pulse_today')}: $today / 100',
                excludeSemantics: true,
                child: SizedBox(
                  width: 168.r,
                  height: 168.r,
                  child: CustomPaint(
                    painter: _StarProgressPainter(progress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$today',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.ivoryOnTeal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '/ 100',
                            textDirection: TextDirection.ltr,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.ivoryOnTeal.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vMd),
              Text(
                l10n.translate(pulse.motivation.l10nKey),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ivoryOnTeal.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarProgressPainter extends CustomPainter {
  const _StarProgressPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Decorative star (khatam) with a progress ring inside, filling
    // clockwise from the top like a clock.
    final star = _starPath(size, 4);
    canvas.drawPath(star, Paint()..color = AppColors.emeraldDeep);
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.brass,
    );
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.29;
    final ring = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = AppColors.brass.withValues(alpha: 0.22),
    );
    if (progress > 0) {
      canvas.drawArc(
        ring,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = AppColors.brass,
      );
    }
  }

  @override
  bool shouldRepaint(_StarProgressPainter old) => old.progress != progress;
}

class _MiniStarPainter extends CustomPainter {
  const _MiniStarPainter({required this.filled, required this.strong});

  final bool filled;
  final bool strong;

  @override
  void paint(Canvas canvas, Size size) {
    final star = _starPath(size, 1);
    if (filled) {
      canvas.drawPath(star, Paint()..color = AppColors.secondaryGold);
    }
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? 2 : 1.2
        ..color = filled ? AppColors.brass : AppColors.glassStrokeStrong,
    );
  }

  @override
  bool shouldRepaint(_MiniStarPainter old) =>
      old.filled != filled || old.strong != strong;
}

/// Today's five prayers as small mihrabs: filled when logged.
class _TodayPrayersCard extends StatelessWidget {
  const _TodayPrayersCard({required this.state});

  final PulseLoaded state;

  static const _prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final done = _prayers.where(state.isPrayerLoggedToday).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.translate('pulse_today_prayers'),
                  style: textTheme.titleMedium,
                ),
              ),
              Text(
                '$done / 5',
                textDirection: TextDirection.ltr,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryGold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          Row(
            children: [
              for (final p in _prayers)
                Expanded(child: _prayerMihrab(context, p)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _prayerMihrab(BuildContext context, String prayer) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final logged = state.isPrayerLoggedToday(prayer);
    final name = l10n.translate(prayer);
    return Semantics(
      label: '$name${logged ? ', ${l10n.logged}' : ''}',
      excludeSemantics: true,
      child: Column(
        children: [
          Container(
            width: 40.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: logged ? AppColors.secondaryGold : Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.r),
                bottom: Radius.circular(6.r),
              ),
              border: Border.all(color: AppColors.brass, width: 1.2),
            ),
            child: Icon(
              logged ? Icons.check_rounded : Icons.remove,
              size: 18.sp,
              color:
                  logged ? AppColors.onAccentFill : AppColors.glassStrokeStrong,
            ),
          ),
          SizedBox(height: AppSpacing.vXs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              maxLines: 1,
              style: textTheme.labelSmall?.copyWith(
                color:
                    logged ? AppColors.secondaryGold : AppColors.textSecondary,
                fontWeight: logged ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Current streak with the last seven days as small stars.
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.pulse});

  final SpiritualPulseEntity pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final days = pulse.dailyPoints;
    final labels = lastDaysWeekdayLabels(locale, count: days.length);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pulse.currentStreak}',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.secondaryGold,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.current_streak, style: textTheme.titleSmall),
                    Text(
                      '${l10n.longest_streak}: ${pulse.longestStreak}',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.brassDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          Row(
            children: [
              for (var i = 0; i < days.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 26.r,
                        height: 26.r,
                        child: CustomPaint(
                          painter: _MiniStarPainter(
                            filled: days[i] > 0,
                            strong: i == days.length - 1,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.vXs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          style: textTheme.labelSmall?.copyWith(
                            color:
                                i == days.length - 1
                                    ? AppColors.secondaryGold
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seven-day chart with the week's and lifetime totals underneath.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.pulse});

  final SpiritualPulseEntity pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    Widget total(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.secondaryGold,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.weekly_activity, style: textTheme.titleMedium),
          SizedBox(height: AppSpacing.vLg),
          WeeklyBars(points: pulse.dailyPoints, showValues: true),
          SizedBox(height: AppSpacing.vMd),
          const Divider(height: 1),
          SizedBox(height: AppSpacing.vMd),
          Row(
            children: [
              total('${weeklyPointsOf(pulse)}', l10n.points_this_week),
              Container(width: 1, height: 32.h, color: AppColors.glassStroke),
              total('${pulse.totalPoints}', l10n.lifetime_points),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seven-day bar chart (oldest first, ending today) with localized weekday
/// labels and one semantics label per bar. Bars are arch-topped.
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
    final arch = BorderRadius.vertical(
      top: Radius.circular(12.w),
      bottom: Radius.circular(3.w),
    );

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
                      borderRadius: arch,
                    ),
                    child: AnimatedFractionallySizedBox(
                      duration: AppDurations.slow,
                      curve: AppDurations.curve,
                      heightFactor: (points[i] / maxValue).clamp(0.06, 1.0),
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: arch,
                          color:
                              points[i] >= kActiveDayPoints
                                  ? AppColors.secondaryGold
                                  : AppColors.secondaryGold.withValues(
                                    alpha: 0.3,
                                  ),
                          border:
                              i == count - 1
                                  ? Border.all(color: AppColors.brass)
                                  : null,
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

/// All badges as star medallions: earned ones filled, the rest locked.
class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  /// Earned badge ids.
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final earned = badges.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.badges, style: textTheme.titleLarge)),
            Text(
              '${earned.length} / ${BadgeIds.all.length}',
              textDirection: TextDirection.ltr,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.brassDeep,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.vMd),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.vMd,
          children: [
            for (final id in BadgeIds.all)
              _medallion(context, id, earned.contains(id)),
          ],
        ),
      ],
    );
  }

  Widget _medallion(BuildContext context, String id, bool isEarned) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final name = l10n.translate(badgeL10nKey(id));
    return SizedBox(
      width: 78.w,
      child: Tooltip(
        message: l10n.translate(badgeDescriptionL10nKey(id)),
        child: Semantics(
          label: isEarned ? name : '$name, ${l10n.translate('badge_locked')}',
          excludeSemantics: true,
          child: Column(
            children: [
              SizedBox(
                width: 56.r,
                height: 56.r,
                child: CustomPaint(
                  painter: _MiniStarPainter(filled: isEarned, strong: isEarned),
                  child: Center(
                    child: Icon(
                      isEarned ? _badgeIcon(id) : Icons.lock_outline_rounded,
                      size: 20.sp,
                      color:
                          isEarned
                              ? AppColors.onAccentFill
                              : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vXs),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: isEarned ? AppColors.textMain : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
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
        Text(l10n.recent_activity, style: textTheme.titleLarge),
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
                        color: AppColors.brassDeep,
                        fontWeight: FontWeight.w700,
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
