import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class IslamicCalendarPage extends StatelessWidget {
  const IslamicCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Hijri date - in a real app, we'd use a Hijri calendar package
    const hijriDate = '12 Shawwal 1445';
    
    final List<Map<String, String>> events = [
      {'event': 'Hajj Season', 'date': '1 - 10 Dhul-Hijjah'},
      {'event': 'Eid ul-Adha', 'date': '10 Dhul-Hijjah'},
      {'event': 'Islamic New Year', 'date': '1 Muharram'},
      {'event': 'Ashura', 'date': '10 Muharram'},
      {'event': 'Ramadan Begins', 'date': '1 Ramadan'},
      {'event': 'Eid ul-Fitr', 'date': '1 Shawwal'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Islamic Calendar', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
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
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    hijriDate,
                    style: TextStyle(color: AppColors.secondaryGold, fontSize: 28.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Hijri Date',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Upcoming Islamic Events',
                style: TextStyle(color: AppColors.textMain, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.h),
            ...events.map((e) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GlassBox(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e['event']!, style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                    Text(e['date']!, style: TextStyle(color: AppColors.secondaryGold, fontSize: 12.sp)),
                  ],
                ),
              ),
            )),
            SizedBox(height: 24.h),
            GlassBox(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                   Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.secondaryGold, size: 20.sp),
                      SizedBox(width: 12.w),
                      const Text('Note', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  const Text(
                    'Islamic dates depend on moon sightings and may vary by region.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
