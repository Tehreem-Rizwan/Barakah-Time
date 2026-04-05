import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class IslamicCalendarPage extends StatelessWidget {
  const IslamicCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';

    final List<Map<String, String>> events = [
      {'event': context.l10n.hajj_season, 'date': '1 - 10 Dhul-Hijjah'},
      {'event': context.l10n.eid_ul_adha, 'date': '10 Dhul-Hijjah'},
      {'event': context.l10n.islamic_new_year, 'date': '1 Muharram'},
      {'event': context.l10n.ashura, 'date': '10 Muharram'},
      {'event': context.l10n.ramadan_begins, 'date': '1 Ramadan'},
      {'event': context.l10n.eid_ul_fitr, 'date': '1 Shawwal'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: Text(context.l10n.islamic_calendar)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            GlassBox(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    hijriDate,
                    style: TextStyle(
                      color: AppColors.secondaryGold,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.hijri_date_label,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.upcoming_events,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ...events.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GlassBox(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e['event']!,
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        e['date']!,
                        style: TextStyle(
                          color: AppColors.secondaryGold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            GlassBox(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.secondaryGold,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        context.l10n.note,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.moon_sighting_note,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
