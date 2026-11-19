import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/datasources/local/settings_prefs.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';

/// Localized name of a prayer key used by [SettingsState.prayerOffsets].
String prayerOffsetName(AppLocalizations l10n, String prayer) =>
    l10n.translate(prayer);

/// Short summary for the Settings tile, e.g. "Fajr +2 · Isha -3".
String prayerOffsetsSummary(AppLocalizations l10n, Map<String, int> offsets) {
  if (offsets.isEmpty) return l10n.adjust_times_desc;
  return [
    for (final p in SettingsPrefs.offsetPrayers)
      if ((offsets[p] ?? 0) != 0)
        '${prayerOffsetName(l10n, p)} \u2066${_signed(offsets[p]!)}\u2069',
  ].join(' · ');
}

String _signed(int n) => n > 0 ? '+$n' : '\u2212${n.abs()}';

/// Bottom sheet with a -/+ stepper per prayer (±30 minutes).
Future<void> showPrayerOffsetsSheet(BuildContext context) {
  final bloc = context.read<SettingsBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.cardDark,
    builder:
        (_) => BlocProvider.value(value: bloc, child: const _OffsetsSheet()),
  );
}

class _OffsetsSheet extends StatelessWidget {
  const _OffsetsSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (p, c) => p.prayerOffsets != c.prayerOffsets,
      builder: (context, state) {
        final offsets = state.prayerOffsets;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.vLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.adjust_times,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.vXs),
                Text(
                  l10n.adjust_times_note,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: AppSpacing.vMd),
                for (final p in SettingsPrefs.offsetPrayers)
                  _OffsetRow(prayer: p, minutes: offsets[p] ?? 0),
                SizedBox(height: AppSpacing.vMd),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            offsets.isEmpty
                                ? null
                                : () => context.read<SettingsBloc>().add(
                                  const ResetPrayerOffsets(),
                                ),
                        style: dialogActionStyle(),
                        child: Text(l10n.reset),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: dialogActionStyle(
                          background: AppColors.secondaryGold,
                          foreground: AppColors.onGold,
                        ),
                        child: Text(l10n.close),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OffsetRow extends StatelessWidget {
  const _OffsetRow({required this.prayer, required this.minutes});

  final String prayer;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<SettingsBloc>();
    const max = SettingsPrefs.maxOffset;
    void set(int m) => bloc.add(UpdatePrayerOffset(prayer, m));

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.vXs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prayerOffsetName(l10n, prayer),
              style: textTheme.titleSmall?.copyWith(fontSize: 15.sp),
            ),
          ),
          IconButton.outlined(
            tooltip: '\u22121',
            onPressed: minutes > -max ? () => set(minutes - 1) : null,
            icon: Icon(Icons.remove_rounded, size: 18.sp),
          ),
          SizedBox(
            width: 76.w,
            child: Text(
              minutes == 0 ? '0' : l10n.minutesShort(minutes),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    minutes == 0
                        ? AppColors.textSecondary
                        : AppColors.secondaryGold,
              ),
            ),
          ),
          IconButton.outlined(
            tooltip: '+1',
            onPressed: minutes < max ? () => set(minutes + 1) : null,
            icon: Icon(Icons.add_rounded, size: 18.sp),
          ),
        ],
      ),
    );
  }
}
