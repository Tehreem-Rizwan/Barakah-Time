import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/ramadan_service.dart';
import '../../data/datasources/remote/adhan_service.dart';
import '../../domain/entities/prayer_times.dart';
import '../../injection_container.dart';
import '../blocs/prayer_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';
import 'hijri_label.dart';

String _time(BuildContext context, DateTime t) {
  final code = Localizations.localeOf(context).languageCode;
  try {
    return DateFormat.jm(code).format(t);
  } catch (_) {
    return DateFormat.jm().format(t);
  }
}

/// Re-schedules sehri/iftar reminders for the coming week.
Future<void> rescheduleRamadanReminders(BuildContext context) async {
  final settings = context.read<SettingsBloc>().state;
  final prayer = context.read<PrayerBloc>().state;
  final service = sl<RamadanService>();
  final notifications = sl<NotificationService>();
  if (!settings.notificationsEnabled || prayer is! PrayerLoaded) return;
  final days = sl<AdhanService>().timesForDays(
    prayer.latitude,
    prayer.longitude,
    DateTime.now(),
    NotificationService.daysAhead,
    method: settings.calculationMethod,
    madhab: settings.asrMadhab,
  );
  await service.reschedule(notifications, days, settings.languageCode);
}

class RamadanPage extends StatefulWidget {
  const RamadanPage({super.key});

  @override
  State<RamadanPage> createState() => _RamadanPageState();
}

class _RamadanPageState extends State<RamadanPage> {
  RamadanService get _service => sl<RamadanService>();
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _adjust(int delta) async {
    await _service.setHijriAdjust(_service.hijriAdjust + delta);
    if (!mounted) return;
    setState(() {});
    await rescheduleRamadanReminders(context);
  }

  Future<void> _toggleReminders(bool on) async {
    final l10n = context.l10n;
    if (on && !context.read<SettingsBloc>().state.notificationsEnabled) {
      showAppSnackBar(context, l10n.translate('reminders_need_notifications'));
      return;
    }
    await _service.setRemindersEnabled(on);
    if (!mounted) return;
    setState(() {});
    await rescheduleRamadanReminders(context);
  }

  Future<void> _editDay(int year, int day, FastDay current) async {
    final result = await showModalBottomSheet<FastDay>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FastDaySheet(day: day, initial: current),
    );
    if (result == null) return;
    await _service.saveDay(year, day, result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = _service.info(_now);
    return AppScaffold(
      title: l10n.translate('ramadan_title'),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          _statusCard(context, info),
          SizedBox(height: AppSpacing.vLg),
          _sehriIftarCard(context),
          SizedBox(height: AppSpacing.vLg),
          _duasCard(context),
          SizedBox(height: AppSpacing.vLg),
          _logCard(context, info),
          SizedBox(height: AppSpacing.vXl),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context, RamadanInfo info) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final adjust = _service.hijriAdjust;
    final title =
        info.isRamadan
            ? l10n
                .translate('ramadan_day_of')
                .replaceAll('{day}', '${info.day}')
                .replaceAll('{len}', '${info.length}')
            : l10n
                .translate('ramadan_starts_in')
                .replaceAll('{n}', '${info.daysUntil}');
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: AppColors.secondaryGold,
                size: 28.sp,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.translate('ramadan_title')} ${info.year}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(title, style: textTheme.titleLarge),
                    if (!info.isRamadan)
                      Text(
                        DateFormat.yMMMMd(
                          Localizations.localeOf(context).languageCode,
                        ).format(info.start),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (info.isRamadan && _isOddNightTonight(context, info)) ...[
            SizedBox(height: AppSpacing.vSm),
            Text(
              l10n.translate('ramadan_qadr_tonight'),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryGold,
              ),
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.translate('ramadan_moon_adjust'),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: '-1',
                onPressed: adjust > -2 ? () => _adjust(-1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(adjust > 0 ? '+$adjust' : '$adjust'),
              IconButton(
                tooltip: '+1',
                onPressed: adjust < 2 ? () => _adjust(1) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            hijriDateLabel(
              DateTime(_now.year, _now.month, _now.day + adjust),
              l10n,
            ),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Islamic nights start at Maghrib: until Fajr it's still the night of
  /// today's date, after that "tonight" is the night of tomorrow's date.
  bool _isOddNightTonight(BuildContext context, RamadanInfo info) {
    final prayer = context.read<PrayerBloc>().state;
    final beforeFajr =
        prayer is PrayerLoaded
            ? _now.isBefore(prayer.prayerTimes.today.fajr)
            : _now.hour < 5;
    final night = beforeFajr ? info.day : info.day + 1;
    return night >= 21 && night <= info.length && night.isOdd;
  }

  Widget _sehriIftarCard(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is! PrayerLoaded) {
          return AppCard(
            padding: AppSpacing.card,
            child: Text(
              l10n.translate('ramadan_need_location'),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        final today = state.prayerTimes.today;
        final tomorrow = state.prayerTimes.tomorrow;
        // Next event: today's sehri end, today's iftar, or tomorrow's sehri.
        final (String key, DateTime at) next =
            _now.isBefore(today.fajr)
                ? ('ramadan_sehri_ends_in', today.fajr)
                : _now.isBefore(today.maghrib)
                ? ('ramadan_iftar_in', today.maghrib)
                : ('ramadan_sehri_ends_in', tomorrow.fajr);
        final sehri = _now.isBefore(today.fajr) ? today.fajr : tomorrow.fajr;
        return AppCard(
          padding: AppSpacing.card,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _timeTile(
                      context,
                      Icons.wb_twilight_rounded,
                      l10n.translate('ramadan_sehri_ends'),
                      _time(context, sehri),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _timeTile(
                      context,
                      Icons.restaurant_rounded,
                      l10n.translate('ramadan_iftar'),
                      _time(context, today.maghrib),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.vMd),
              Text(
                l10n.translate(next.$1),
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                formatCountdown(next.$2.difference(_now)),
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.secondaryGold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.translate('ramadan_reminders')),
                subtitle: Text(
                  l10n.translate('ramadan_reminders_desc'),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _service.remindersEnabled,
                onChanged: _toggleReminders,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: AppSpacing.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondaryGold),
          SizedBox(height: AppSpacing.vXs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _duasCard(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    Widget dua(String titleKey, String arabic, String meaningKey) => Padding(
      padding: EdgeInsetsDirectional.only(top: AppSpacing.vMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.translate(titleKey),
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.secondaryGold,
            ),
          ),
          SizedBox(height: AppSpacing.vXs),
          ArabicText(arabic, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.vXs),
          Text(
            l10n.translate(meaningKey),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('ramadan_duas'), style: textTheme.titleMedium),
          dua(
            'ramadan_sehri_niyyah',
            'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
            'ramadan_sehri_niyyah_meaning',
          ),
          dua(
            'ramadan_iftar_dua',
            'اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
            'ramadan_iftar_dua_meaning',
          ),
          dua(
            'ramadan_iftar_dua2',
            'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللّٰهُ',
            'ramadan_iftar_dua2_meaning',
          ),
          dua(
            'ramadan_qadr_dua',
            'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
            'ramadan_qadr_dua_meaning',
          ),
        ],
      ),
    );
  }

  Widget _logCard(BuildContext context, RamadanInfo info) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final year = _service.logYear(_now);
    final log = _service.loadLog(year);
    final current = info.isRamadan && info.year == year;
    final fasted = log.values.where((d) => d.status == FastStatus.fasted).length;
    final missed = log.values.where((d) => d.status == FastStatus.missed).length;
    final taraweeh = log.values.where((d) => d.taraweeh).length;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.translate('ramadan_log')} · $year',
            style: textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.vSm),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '$fasted',
                  label: l10n.translate('ramadan_fasted'),
                  valueColor: AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: '$missed',
                  label: l10n.translate('ramadan_missed'),
                  valueColor: AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: '$taraweeh',
                  label: l10n.translate('ramadan_taraweeh'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          Text(
            l10n.translate('ramadan_log_hint'),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var d = 1; d <= 30; d++)
                _dayCell(
                  context,
                  d,
                  log[d] ?? FastDay.empty,
                  enabled: !current || d <= info.day,
                  today: current && d == info.day,
                  onTap: () => _editDay(year, d, log[d] ?? FastDay.empty),
                ),
            ],
          ),
          if (missed > 0) ...[
            SizedBox(height: AppSpacing.vMd),
            Text(
              l10n
                  .translate('ramadan_qaza_fasts')
                  .replaceAll('{n}', '$missed'),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    int day,
    FastDay entry, {
    required bool enabled,
    required bool today,
    required VoidCallback onTap,
  }) {
    final l10n = context.l10n;
    final Color bg = switch (entry.status) {
      FastStatus.fasted => AppColors.success.withValues(alpha: 0.55),
      FastStatus.missed => AppColors.warning.withValues(alpha: 0.45),
      FastStatus.none => AppColors.glassFill,
    };
    final qadr = day >= 21 && day.isOdd;
    final status = switch (entry.status) {
      FastStatus.fasted => l10n.translate('ramadan_fasted'),
      FastStatus.missed => l10n.translate('ramadan_missed'),
      FastStatus.none => '',
    };
    return Semantics(
      button: enabled,
      label: '${l10n.translate('ramadan_day')} $day $status',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side:
                today
                    ? const BorderSide(color: AppColors.secondaryGold, width: 2)
                    : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: enabled ? onTap : null,
            child: Stack(
              children: [
                Center(child: Text('$day')),
                if (qadr)
                  const PositionedDirectional(
                    top: 2,
                    end: 2,
                    child: Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: AppColors.secondaryGold,
                    ),
                  ),
                if (entry.taraweeh)
                  const PositionedDirectional(
                    bottom: 2,
                    start: 2,
                    child: Icon(
                      Icons.nights_stay_rounded,
                      size: 10,
                      color: AppColors.info,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FastDaySheet extends StatefulWidget {
  const _FastDaySheet({required this.day, required this.initial});

  final int day;
  final FastDay initial;

  @override
  State<_FastDaySheet> createState() => _FastDaySheetState();
}

class _FastDaySheetState extends State<_FastDaySheet> {
  late FastStatus _status = widget.initial.status;
  late bool _taraweeh = widget.initial.taraweeh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.translate('ramadan_day')} ${widget.day}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.vMd),
            SegmentedButton<FastStatus>(
              segments: [
                ButtonSegment(
                  value: FastStatus.fasted,
                  label: Text(l10n.translate('ramadan_fasted')),
                  icon: const Icon(Icons.check_rounded),
                ),
                ButtonSegment(
                  value: FastStatus.missed,
                  label: Text(l10n.translate('ramadan_missed')),
                  icon: const Icon(Icons.close_rounded),
                ),
                ButtonSegment(
                  value: FastStatus.none,
                  label: Text(l10n.translate('ramadan_not_set')),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.translate('ramadan_prayed_taraweeh')),
              value: _taraweeh,
              onChanged: (v) => setState(() => _taraweeh = v),
            ),
            SizedBox(height: AppSpacing.vSm),
            PrimaryButton(
              label: l10n.save,
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop(FastDay(status: _status, taraweeh: _taraweeh)),
            ),
            SizedBox(height: AppSpacing.vSm),
          ],
        ),
      ),
    );
  }
}

/// Home-screen card shown during Ramadan and in the 10 days before it.
class RamadanHomeCard extends StatelessWidget {
  const RamadanHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!sl.isRegistered<RamadanService>()) return const SizedBox.shrink();
    final l10n = context.l10n;
    final info = sl<RamadanService>().info(DateTime.now());
    if (!info.isRamadan && info.daysUntil > 10) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final prayer = context.watch<PrayerBloc>().state;
    final subtitle =
        info.isRamadan && prayer is PrayerLoaded
            ? '${l10n.translate('ramadan_sehri_ends')} ${_time(context, prayer.prayerTimes.today.fajr)} · '
                '${l10n.translate('ramadan_iftar')} ${_time(context, prayer.prayerTimes.today.maghrib)}'
            : l10n.translate('ramadan_prepare');
    return Padding(
      padding: EdgeInsetsDirectional.only(top: AppSpacing.vLg),
      child: AppCard(
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RamadanPage()),
            ),
        border: Border.all(
          color: AppColors.secondaryGold.withValues(alpha: 0.4),
        ),
        padding: AppSpacing.card,
        child: Row(
          children: [
            Icon(
              Icons.nightlight_round,
              color: AppColors.secondaryGold,
              size: 28.sp,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.isRamadan
                        ? l10n
                            .translate('ramadan_day_of')
                            .replaceAll('{day}', '${info.day}')
                            .replaceAll('{len}', '${info.length}')
                        : l10n
                            .translate('ramadan_starts_in')
                            .replaceAll('{n}', '${info.daysUntil}'),
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
