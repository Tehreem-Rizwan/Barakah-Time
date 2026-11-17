import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/localization/app_localizations.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../injection_container.dart';
import '../blocs/location_bloc.dart';
import '../blocs/prayer_actions.dart';
import '../blocs/prayer_bloc.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';
import 'hijri_label.dart';

/// Icons for the five prayers (shared by Home and the Prayer Times page).
const Map<PrayerName, IconData> prayerIcons = {
  PrayerName.fajr: Icons.wb_twilight_outlined,
  PrayerName.dhuhr: Icons.wb_sunny_outlined,
  PrayerName.asr: Icons.wb_cloudy_outlined,
  PrayerName.maghrib: Icons.nightlight_round_outlined,
  PrayerName.isha: Icons.nights_stay_outlined,
};

/// Keeps the last loaded times visible while a reload is in flight.
bool keepLoadedWhileReloading(PrayerState previous, PrayerState current) =>
    !(current is PrayerLoading && previous is PrayerLoaded);

/// Reloads prayer times + location from the current settings and completes
/// when the reload finished (or after a timeout). For pull-to-refresh.
Future<void> refreshPrayerTimes(BuildContext context) async {
  final bloc = context.read<PrayerBloc>();
  final done = bloc.stream
      .firstWhere((s) => s is! PrayerLoading)
      .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
  reloadPrayerTimesFromSettings(context);
  await done;
}

/// Localized (title, message) for a prayer-times error.
({String title, String message}) prayerErrorText(
  AppLocalizations l10n,
  PrayerError state,
) {
  switch (state.locationFailure) {
    case LocationFailure.serviceDisabled:
      return (
        title: l10n.location_services_disabled,
        message: l10n.set_manual_location_hint,
      );
    case LocationFailure.deniedForever:
      return (
        title: l10n.location_access_required,
        message: l10n.location_permission_denied_forever,
      );
    case LocationFailure.denied:
      return (
        title: l10n.location_access_required,
        message:
            '${l10n.location_permission_denied} ${l10n.set_manual_location_hint}',
      );
    case LocationFailure.timeout:
      return (
        title: l10n.location_unavailable,
        message: '${l10n.location_timeout} ${l10n.set_manual_location_hint}',
      );
    case LocationFailure.unknown:
    case null:
      return (
        title: l10n.location_unavailable,
        message: l10n.set_manual_location_hint,
      );
  }
}

/// [StateView.error] for a prayer-times failure, with "Open settings" as a
/// secondary action when the fix is in system settings.
class PrayerErrorView extends StatelessWidget {
  const PrayerErrorView({super.key, required this.state});

  final PrayerError state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = prayerErrorText(l10n, state);
    String? secondaryLabel;
    VoidCallback? onSecondary;
    switch (state.locationFailure) {
      case LocationFailure.serviceDisabled:
        secondaryLabel = l10n.location_settings;
        onSecondary = () => sl<LocationService>().openLocationSettings();
        break;
      case LocationFailure.deniedForever:
        secondaryLabel = l10n.open_settings;
        onSecondary = () => sl<LocationService>().openAppSettings();
        break;
      default:
        break;
    }
    return StateView.error(
      icon: Icons.location_off_outlined,
      message: '${text.title}\n${text.message}',
      onRetry:
          () => reloadPrayerTimesFromSettings(
            context,
            forceLocationRefresh: true,
          ),
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
    );
  }
}

/// Rebuilds [builder] with the current next prayer only when it changes
/// (at the next prayer time or midnight) — never every second. The ticking
/// countdown is isolated in [PrayerCountdown].
class NextPrayerBuilder extends StatefulWidget {
  const NextPrayerBuilder({
    super.key,
    required this.times,
    required this.builder,
  });

  final PrayerTimesEntity times;
  final Widget Function(BuildContext context, NextPrayer next, DateTime now)
  builder;

  @override
  State<NextPrayerBuilder> createState() => _NextPrayerBuilderState();
}

class _NextPrayerBuilderState extends State<NextPrayerBuilder> {
  Timer? _wake;
  DateTime? _refreshRequestedFor;

  @override
  void dispose() {
    _wake?.cancel();
    super.dispose();
  }

  void _schedule(DateTime now, NextPrayer next) {
    _wake?.cancel();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final at = next.time.isBefore(midnight) ? next.time : midnight;
    final delay = at.difference(now) + const Duration(milliseconds: 500);
    _wake = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (mounted) setState(() {});
    });
  }

  /// Times for a previous day (e.g. resumed after midnight): recompute once.
  void _maybeRequestRefresh(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (widget.times.date != today && _refreshRequestedFor != today) {
      _refreshRequestedFor = today;
      context.read<PrayerBloc>().add(RefreshPrayerTimes());
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    _maybeRequestRefresh(now);
    final next = widget.times.nextPrayerAt(now);
    _schedule(now, next);
    return widget.builder(context, next, now);
  }
}

/// Live "HH:MM:SS" countdown to [target]; only this widget rebuilds every
/// second. Never shows a negative value.
class PrayerCountdown extends StatefulWidget {
  const PrayerCountdown({
    super.key,
    required this.target,
    this.style,
    this.clock = DateTime.now,
  });

  final DateTime target;
  final TextStyle? style;

  /// Injectable for tests.
  final DateTime Function() clock;

  @override
  State<PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<PrayerCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target.difference(widget.clock());
    final text = formatCountdown(
      remaining.isNegative ? Duration.zero : remaining,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        maxLines: 1,
        textDirection: TextDirection.ltr,
        style: (widget.style ?? Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

/// Current location label: manual city / GPS place / unknown city.
class PrayerLocationText extends StatelessWidget {
  const PrayerLocationText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16.sp,
          color: AppColors.secondaryGold,
        ),
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              var text = l10n.locating;
              if (state is LocationLoaded) {
                text =
                    state.isPlaceUnknown
                        ? l10n.unknown_city
                        : state.displayName;
              } else if (state is LocationError) {
                text = l10n.location_unavailable;
              }
              return Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    style ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.prayer_times,
      body: BlocBuilder<PrayerBloc, PrayerState>(
        buildWhen: keepLoadedWhileReloading,
        builder: (context, state) {
          if (state is PrayerLoaded) {
            return RefreshIndicator(
              onRefresh: () => refreshPrayerTimes(context),
              child: NextPrayerBuilder(
                times: state.prayerTimes,
                builder:
                    (context, next, now) =>
                        _PrayerTimesList(times: state.prayerTimes, next: next),
              ),
            );
          }
          if (state is PrayerError) {
            return RefreshIndicator(
              onRefresh: () => refreshPrayerTimes(context),
              child: PrayerErrorView(state: state),
            );
          }
          return StateView.loading(message: context.l10n.locating);
        },
      ),
    );
  }
}

class _PrayerTimesList extends StatelessWidget {
  const _PrayerTimesList({required this.times, required this.next});

  final PrayerTimesEntity times;
  final NextPrayer next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <Widget>[];
    for (final prayer in PrayerName.values) {
      rows.add(
        _PrayerRow(
          icon: prayerIcons[prayer]!,
          label: l10n.translate(prayer.key),
          time: times.today.timeOf(prayer),
          highlighted: !next.isTomorrow && next.prayer == prayer,
          trailing: _LogPrayerButton(times: times, prayer: prayer),
        ),
      );
      if (prayer == PrayerName.fajr) {
        rows.add(
          _PrayerRow(
            icon: Icons.wb_sunny_outlined,
            label: l10n.sunrise,
            time: times.sunrise,
            highlighted: false,
            dimmed: true,
          ),
        );
      }
    }
    if (next.isTomorrow) {
      rows.add(
        _PrayerRow(
          icon: prayerIcons[PrayerName.fajr]!,
          label: l10n.tomorrow_fajr,
          time: times.tomorrow.fajr,
          highlighted: true,
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.page,
      children: [
        _PrayerHeaderCard(times: times, next: next),
        SizedBox(height: AppSpacing.vXl),
        for (final row in rows) ...[row, SizedBox(height: AppSpacing.vMd)],
      ],
    );
  }
}

class _PrayerHeaderCard extends StatelessWidget {
  const _PrayerHeaderCard({required this.times, required this.next});

  final PrayerTimesEntity times;
  final NextPrayer next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final nextName =
        next.isTomorrow ? l10n.tomorrow_fajr : l10n.translate(next.prayer.key);

    return AppCard(
      blur: true,
      padding: AppSpacing.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The table always shows today's times, so this date matches it.
          Text(
            gregorianDateLabel(times.date, locale),
            style: textTheme.titleMedium,
          ),
          Text(
            hijriDateLabel(times.date, l10n),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          const PrayerLocationText(),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.vLg),
            child: const Divider(height: 1),
          ),
          Text(
            l10n.next_prayer,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium,
                    ),
                    Text(
                      DateFormat.jm(locale).format(next.time),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Flexible(
                child: Container(
                  padding: AppSpacing.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGold.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: AppColors.secondaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: PrayerCountdown(
                    target: next.time,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.secondaryGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.highlighted,
    this.dimmed = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final DateTime time;
  final bool highlighted;
  final bool dimmed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final foreground =
        highlighted
            ? AppColors.secondaryGold
            : (dimmed ? AppColors.textSecondary : AppColors.textMain);

    return AppCard(
      padding: AppSpacing.only(start: 16, top: 8, bottom: 8, end: 4),
      border:
          highlighted
              ? Border.all(
                color: AppColors.secondaryGold.withValues(alpha: 0.5),
              )
              : null,
      color: highlighted ? AppColors.secondaryGold : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.all(8),
              decoration: BoxDecoration(
                color:
                    highlighted
                        ? AppColors.secondaryGold.withValues(alpha: 0.2)
                        : AppColors.glassBase,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    highlighted
                        ? AppColors.secondaryGold
                        : AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (dimmed ? textTheme.bodyMedium : textTheme.titleMedium)
                    ?.copyWith(
                      color:
                          highlighted
                              ? AppColors.textMain
                              : (dimmed
                                  ? AppColors.textSecondary
                                  : AppColors.textMain),
                      fontWeight:
                          highlighted ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat.jm(locale).format(time),
              style: (dimmed ? textTheme.bodyMedium : textTheme.titleMedium)
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
            // Same width with or without a log button so times align.
            SizedBox(width: AppSizes.minTapTarget, child: trailing),
          ],
        ),
      ),
    );
  }
}

class _LogPrayerButton extends StatelessWidget {
  const _LogPrayerButton({required this.times, required this.prayer});

  final PrayerTimesEntity times;
  final PrayerName prayer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = l10n.translate(prayer.key);
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final isLogged =
            state is PulseLoaded && state.isPrayerLoggedToday(prayer.key);
        final started = times.hasStarted(prayer, DateTime.now());
        final label =
            isLogged
                ? l10n.prayer_logged_semantics.replaceAll('{prayer}', name)
                : l10n.log_prayer_semantics.replaceAll('{prayer}', name);
        return Semantics(
          checked: isLogged,
          child: IconButton(
            tooltip: label,
            icon: Icon(
              isLogged
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  isLogged
                      ? AppColors.success
                      : (started
                          ? AppColors.secondaryGold
                          : AppColors.textTertiary),
              size: 26.sp,
            ),
            onPressed: () => _logPrayer(context, isLogged: isLogged),
          ),
        );
      },
    );
  }

  void _logPrayer(BuildContext context, {required bool isLogged}) {
    final l10n = context.l10n;
    final name = l10n.translate(prayer.key);

    if (!times.hasStarted(prayer, DateTime.now())) {
      showAppSnackBar(
        context,
        l10n.prayer_not_started.replaceAll('{prayer}', name),
      );
      return;
    }
    if (isLogged) {
      showAppSnackBar(
        context,
        l10n.prayer_already_logged.replaceAll('{prayer}', name),
      );
      return;
    }

    final activity = SpiritualActivity(
      // Deterministic id => logging twice is a no-op.
      id: 'prayer_${prayer.key}_${DateFormat('yyyyMMdd').format(times.date)}',
      type: 'prayer',
      subType: prayer.key,
      timestamp: times.today.timeOf(prayer),
      points: 15,
    );
    context.read<PulseBloc>().add(
      LogActivity(
        activity,
        onResult: (added) {
          if (!context.mounted) return;
          showAppSnackBar(
            context,
            added
                ? '$name ${l10n.logged_to_pulse}'
                : l10n.prayer_already_logged.replaceAll('{prayer}', name),
            type: added ? SnackType.success : SnackType.info,
          );
        },
      ),
    );
  }
}
