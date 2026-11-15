import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/islamic_events.dart';
import '../widgets/widgets.dart';

/// Layout of a Hijri month for a 7-column grid.
class HijriMonthGrid {
  final int year;
  final int month;
  final int daysInMonth;

  /// Empty cells before day 1 (relative to [firstDayOfWeekIndex]).
  final int leadingBlanks;

  /// Day of month for [today], or null when today is not in this month.
  final int? todayDay;

  const HijriMonthGrid({
    required this.year,
    required this.month,
    required this.daysInMonth,
    required this.leadingBlanks,
    required this.todayDay,
  });

  /// [firstDayOfWeekIndex]: 0 = Sunday … 6 = Saturday (as in
  /// `MaterialLocalizations.firstDayOfWeekIndex`).
  factory HijriMonthGrid.forDate(DateTime today, int firstDayOfWeekIndex) {
    final h = HijriCalendar.fromDate(today);
    final days = h.getDaysInMonth(h.hYear, h.hMonth);
    final first = HijriCalendar().hijriToGregorian(h.hYear, h.hMonth, 1);
    final sundayIndex = first.weekday % 7; // DateTime: Mon=1 … Sun=7
    return HijriMonthGrid(
      year: h.hYear,
      month: h.hMonth,
      daysInMonth: days,
      leadingBlanks: (sundayIndex - firstDayOfWeekIndex + 7) % 7,
      todayDay: h.hDay,
    );
  }
}

class IslamicCalendarPage extends StatelessWidget {
  const IslamicCalendarPage({super.key});

  DateFormat _dateFormat(String pattern, String locale) {
    try {
      return DateFormat(pattern, locale);
    } catch (_) {
      return DateFormat(pattern);
    }
  }

  String _daysLabel(AppLocalizations l10n, int days) {
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.tomorrow;
    return l10n.in_days.replaceAll('{n}', '$days');
  }

  String _monthName(AppLocalizations l10n, int month) =>
      l10n.translate('hijri_month_$month');

  /// Full Hijri date. Arabic uses the hijri package's own Arabic formatting
  /// (Arabic-Indic digits); other languages use localized month names.
  String _hijriDate(AppLocalizations l10n, String locale, HijriCalendar h) {
    if (locale == 'ar') {
      // The package keeps the language in a static; restore it after use.
      final previous = HijriCalendar.language;
      HijriCalendar.setLocal('ar');
      final text = h.toFormat('dd MMMM yyyy');
      HijriCalendar.language = previous;
      return text;
    }
    return '${h.hDay} ${_monthName(l10n, h.hMonth)} ${h.hYear}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final events = IslamicEvents.upcoming(now);
    final longDate = _dateFormat('EEEE, d MMMM yyyy', locale);
    final shortDate = _dateFormat('d MMM yyyy', locale);
    final materialL10n = MaterialLocalizations.of(context);
    final grid = HijriMonthGrid.forDate(now, materialL10n.firstDayOfWeekIndex);

    return AppScaffold(
      title: l10n.islamic_calendar,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          AppCard(
            blur: true,
            color: AppColors.emeraldDeep,
            padding: AppSpacing.all(24),
            child: Column(
              children: [
                Text(
                  longDate.format(now),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.vMd),
                Text(
                  _hijriDate(l10n, locale, hijri),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 28.sp,
                    color: AppColors.secondaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.vSm),
                Text(
                  l10n.hijri_date_label,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          SectionHeader(
            title: '${_monthName(l10n, grid.month)} ${grid.year}',
            icon: Icons.calendar_month_outlined,
          ),
          SizedBox(height: AppSpacing.vMd),
          AppCard(
            padding: AppSpacing.all(12),
            child: _MonthGrid(grid: grid, materialL10n: materialL10n),
          ),
          SizedBox(height: AppSpacing.vXl),
          SectionHeader(
            title: l10n.upcoming_events,
            icon: Icons.event_outlined,
          ),
          SizedBox(height: AppSpacing.vMd),
          for (final e in events)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vMd),
              child: AppCard(
                padding: AppSpacing.tile,
                borderRadius: AppRadius.mdAll,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate(e.def.key),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vXs),
                          Text(
                            '${shortDate.format(e.gregorian)} • '
                            '${e.def.hijriDay} ${_monthName(l10n, e.def.hijriMonth)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      _daysLabel(l10n, e.daysRemaining),
                      textAlign: TextAlign.end,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: AppSpacing.vMd),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.secondaryGold,
                      size: 20.sp,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.note,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vSm),
                Text(
                  l10n.moon_sighting_note,
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.grid, required this.materialL10n});

  final HijriMonthGrid grid;
  final MaterialLocalizations materialL10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = materialL10n.firstDayOfWeekIndex;
    final weekdays = [
      for (var i = 0; i < 7; i++) materialL10n.narrowWeekdays[(first + i) % 7],
    ];
    final cells = grid.leadingBlanks + grid.daysInMonth;
    final rows = (cells / 7).ceil();

    Widget cell(int index) {
      final day = index - grid.leadingBlanks + 1;
      if (day < 1 || day > grid.daysInMonth) return const SizedBox.shrink();
      final isToday = day == grid.todayDay;
      return Center(
        child: Container(
          width: 34.r,
          height: 34.r,
          alignment: AlignmentDirectional.center,
          decoration:
              isToday
                  ? const BoxDecoration(
                    color: AppColors.secondaryGold,
                    shape: BoxShape.circle,
                  )
                  : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$day',
              style: textTheme.bodyMedium?.copyWith(
                color: isToday ? AppColors.onGold : AppColors.textMain,
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.vSm),
        for (var r = 0; r < rows; r++)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vXs),
            child: Row(
              children: [
                for (var c = 0; c < 7; c++) Expanded(child: cell(r * 7 + c)),
              ],
            ),
          ),
      ],
    );
  }
}
