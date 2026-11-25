import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/recitations.dart';
import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../injection_container.dart';
import '../blocs/prayer_bloc.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';
import 'surah_detail_page.dart';

/// Home card with the recitations for the night (Isha → Fajr) and Surah
/// Al-Kahf on Friday (Thursday Maghrib → Friday Maghrib). Hidden otherwise.
class RecitationCard extends StatefulWidget {
  const RecitationCard({super.key, this.clock});

  /// Overridable in tests.
  final DateTime Function()? clock;

  @override
  State<RecitationCard> createState() => _RecitationCardState();
}

class _RecitationCardState extends State<RecitationCard> {
  Timer? _timer;
  RecitationTracker? _tracker;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    if (sl.isRegistered<SharedPreferences>()) {
      _tracker = RecitationTracker(sl<SharedPreferences>());
    }
    // Re-check every minute so the card appears at Isha / disappears at
    // Fajr without reopening the app.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _open(Recitation r) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    try {
      final surahs = await sl<QuranRepository>().getSurahs();
      final surah = surahs.firstWhere((s) => s.number == r.surah);
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => SurahDetailPage(surah: surah, initialAyah: r.ayah),
        ),
      );
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, l10n.surah_load_error, type: SnackType.error);
      }
    }
  }

  Future<void> _toggle(
    String windowKey,
    List<Recitation> items,
    bool done,
  ) async {
    final tracker = _tracker;
    if (tracker == null) return;
    await tracker.setDone(windowKey, items.map((r) => r.id), done);
    if (done && mounted) {
      // Points once per item per night/Friday (the id makes it idempotent).
      for (final r in items) {
        context.read<PulseBloc>().add(
          LogActivity(
            SpiritualActivity(
              id: 'recite_${r.id}_$windowKey',
              type: 'quran',
              subType: r.arabicName,
              timestamp: DateTime.now(),
              points: 10,
            ),
          ),
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerBloc>().state;
    final today = prayer is PrayerLoaded ? prayer.prayerTimes.today : null;
    final now = _now();
    final windows = Recitations.activeWindows(now, today);
    if (windows.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final w in windows)
          Padding(
            padding: EdgeInsetsDirectional.only(top: AppSpacing.vLg),
            child: _buildCard(context, w, Recitations.windowKey(w, now, today)),
          ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, RecitationWindow w, String key) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final done = _tracker?.doneIn(key) ?? const <String>{};
    final night = w == RecitationWindow.night;
    final counted = night ? Recitations.nightSunnah : const [Recitations.kahf];
    final doneCount = counted.where((r) => done.contains(r.id)).length;

    Widget row(String label, List<Recitation> items, {List<Widget>? pills}) {
      final isDone = items.every((r) => done.contains(r.id));
      return InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _open(items.first),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 2.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AppColors.textSecondary : null,
                      ),
                    ),
                    if (pills != null) ...[
                      SizedBox(height: 4.h),
                      Wrap(spacing: 6.w, runSpacing: 4.h, children: pills),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: isDone ? l10n.mark_not_done : l10n.mark_done,
                onPressed: () => _toggle(key, items, !isDone),
                icon: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isDone ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget pill(Recitation r) => ActionChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => _open(r),
      label: ArabicText(r.arabicName, fontSize: 14.sp, height: 1.4),
      side: BorderSide(color: AppColors.brass.withValues(alpha: 0.5)),
      backgroundColor: Colors.transparent,
    );

    return AppCard(
      border: Border.all(color: AppColors.secondaryGold.withValues(alpha: 0.4)),
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                night ? Icons.nightlight_round : Icons.mosque_outlined,
                color: AppColors.secondaryGold,
                size: 26.sp,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      night ? l10n.night_rec_title : l10n.friday_rec_title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      night
                          ? l10n.night_rec_subtitle
                          : l10n.friday_rec_subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$doneCount/${counted.length}',
                textDirection: TextDirection.ltr,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vSm),
          if (night) ...[
            row(l10n.rec_ayat_kursi, const [Recitations.ayatKursi]),
            row(l10n.rec_baqarah_end, const [Recitations.baqarahEnd]),
            row(l10n.rec_mulk, const [Recitations.mulk]),
            row(
              l10n.rec_quls,
              Recitations.quls,
              pills: [for (final r in Recitations.quls) pill(r)],
            ),
            Divider(height: AppSpacing.vLg),
            Text(
              l10n.rec_also_common,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [for (final r in Recitations.commonNight) pill(r)],
            ),
          ] else
            row(l10n.rec_kahf, const [Recitations.kahf]),
        ],
      ),
    );
  }
}
