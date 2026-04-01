import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import 'names_all_page.dart';
import 'tasbeeh_page.dart';
import 'quran_page.dart';
import 'pulse_page.dart';
import 'prayer_times_page.dart';
import 'duas_page.dart';
import 'qibla_page.dart';
import 'zakat_calculator_page.dart';
import 'islamic_calendar_page.dart';
import 'mosque_finder_page.dart';
import 'hajj_guide_page.dart';

class ToolsGridPage extends StatelessWidget {
  const ToolsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {
        'icon': Icons.mosque,
        'label': 'Prayer',
        'page': const PrayerTimesPage(),
      },
      {'icon': Icons.menu_book, 'label': 'Quran', 'page': const QuranPage()},
      {'icon': Icons.timer, 'label': 'Tasbeeh', 'page': const TasbeehPage()},
      {
        'icon': Icons.auto_awesome,
        'label': '99 Names',
        'page': const NamesOfAllahPage(),
      },
      {'icon': Icons.explore, 'label': 'Qibla', 'page': const QiblaPage()},
      {'icon': Icons.favorite, 'label': 'Duas', 'page': const DuasPage()},
      {
        'icon': Icons.calculate,
        'label': 'Zakat',
        'page': const ZakatCalculatorPage(),
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Calendar',
        'page': const IslamicCalendarPage(),
      },
      {
        'icon': Icons.location_on,
        'label': 'Mosques',
        'page': const MosqueFinderPage(),
      },
      {
        'icon': Icons.directions_walk,
        'label': 'Hajj Guide',
        'page': const HajjGuidePage(),
      },
      {'icon': Icons.bolt, 'label': 'Pulse', 'page': const PulsePage()},
      {'icon': Icons.settings, 'label': 'Settings', 'page': null},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text(
          'All Tools',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(24.sp),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.85,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return GestureDetector(
            onTap: () {
              if (tool['page'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => tool['page']),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${tool['label']} coming soon!')),
                );
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: GlassBox(
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        tool['icon'],
                        color: AppColors.secondaryGold,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  tool['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
