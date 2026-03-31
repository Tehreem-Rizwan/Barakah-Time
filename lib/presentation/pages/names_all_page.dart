import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class NamesOfAllahPage extends StatelessWidget {
  const NamesOfAllahPage({super.key});

  final List<Map<String, String>> names = const [
    {'name': 'Ar-Rahman', 'meaning': 'The Most Gracious', 'arabic': 'الرحمن'},
    {'name': 'Ar-Rahim', 'meaning': 'The Most Merciful', 'arabic': 'الرحيم'},
    {'name': 'Al-Malik', 'meaning': 'The Sovereign Lord', 'arabic': 'الملك'},
    {'name': 'Al-Quddus', 'meaning': 'The Holy', 'arabic': 'القدوس'},
    {'name': 'As-Salam', 'meaning': 'The Source of Peace', 'arabic': 'السلام'},
    // ... more names can be added
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('99 Names of Allah', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(24.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.1,
        ),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return GlassBox(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name['arabic']!,
                  style: TextStyle(color: AppColors.secondaryGold, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  name['name']!,
                  style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  name['meaning']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
