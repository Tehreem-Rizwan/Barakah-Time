import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';

/// Localized, human-readable label for an activity
/// (e.g. "Fajr prayer", "Quran reading · Al-Fatiha", "Dhikr").
String activityLabel(AppLocalizations l10n, SpiritualActivity activity) {
  final sub = activity.subType?.trim();
  switch (activity.type) {
    case 'prayer':
      final prayer = (sub == null || sub.isEmpty) ? '' : l10n.translate(sub);
      return l10n.activity_prayer.replaceAll('{prayer}', prayer).trim();
    case 'quran':
      return (sub == null || sub.isEmpty)
          ? l10n.activity_quran
          : '${l10n.activity_quran} · $sub';
    case 'dhikr':
      return l10n.activity_dhikr;
    default:
      return l10n.activity_other;
  }
}

/// Icon for an activity type.
IconData activityIcon(SpiritualActivity activity) {
  switch (activity.type) {
    case 'prayer':
      return Icons.mosque_outlined;
    case 'quran':
      return Icons.menu_book_outlined;
    case 'dhikr':
      return Icons.touch_app_outlined;
    default:
      return Icons.star_outline_rounded;
  }
}

/// Formats [date] with [pattern] in the current locale, falling back to
/// English if the locale's date symbols aren't available.
String formatLocalizedDate(
  BuildContext context,
  DateTime date,
  DateFormat Function(String locale) pattern,
) {
  try {
    return pattern(Localizations.localeOf(context).languageCode).format(date);
  } catch (_) {
    return pattern('en').format(date);
  }
}

/// Full activity history, grouped by day; updates live from [PulseBloc].
class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  String _dayLabel(BuildContext context, DateTime day) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Calendar-day difference (UTC avoids DST's 23/25-hour days).
    final diff = DateTime.utc(today.year, today.month, today.day)
        .difference(DateTime.utc(day.year, day.month, day.day))
        .inDays;
    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.profile_yesterday;
    return formatLocalizedDate(context, day, (l) => DateFormat.yMMMEd(l));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.profile_activity_history,
      body: BlocBuilder<PulseBloc, PulseState>(
        builder: (context, state) {
          if (state is PulseInitial || state is PulseLoading) {
            return const StateView.loading();
          }
          if (state is PulseError) {
            return StateView.error(
              message: l10n.pulse_load_failed,
              onRetry: () => context.read<PulseBloc>().add(LoadPulseData()),
            );
          }
          final activities = [
            ...(state as PulseLoaded).pulse.allActivities,
          ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (activities.isEmpty) {
            return StateView.empty(
              icon: Icons.history_rounded,
              message: l10n.no_recent_activity,
            );
          }

          // Group by calendar day (activities are sorted newest first).
          final groups = <DateTime, List<SpiritualActivity>>{};
          for (final a in activities) {
            final t = a.timestamp.toLocal();
            groups.putIfAbsent(DateTime(t.year, t.month, t.day), () => []).add(a);
          }

          return ListView(
            padding: AppSpacing.page,
            children: [
              for (final entry in groups.entries) ...[
                SectionHeader(
                  title: _dayLabel(context, entry.key),
                  padding: AppSpacing.only(top: 8, bottom: 8, start: 4),
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < entry.value.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _ActivityRow(activity: entry.value[i]),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.vLg),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final SpiritualActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final when = formatLocalizedDate(
      context,
      activity.timestamp.toLocal(),
      (l) => DateFormat.yMMMd(l).add_jm(),
    );
    return ActionTile(
      icon: activityIcon(activity),
      title: activityLabel(l10n, activity),
      subtitle: when,
      trailing: Text(
        l10n.points_gained.replaceAll('{n}', '${activity.points}'),
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.secondaryGold,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
