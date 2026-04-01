import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class HajjGuidePage extends StatelessWidget {
  const HajjGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {'step': 'Ihram', 'desc': 'Put on the Ihram and make your Niyyah (intention).'},
      {'step': 'Mina', 'desc': 'Stay in Mina on the 8th of Dhul-Hijjah.'},
      {'step': 'Arafat', 'desc': 'Stand in Arafat on the 9th of Dhul-Hijjah (The peak of Hajj).'},
      {'step': 'Muzdalifah', 'desc': 'Collect pebbles and stay overnight.'},
      {'step': 'Ramy al-Jamarat', 'desc': 'Stoning the Jamarat (the pillars representing devil).'},
      {'step': 'Qurbani', 'desc': 'Hady (sacrifice of an animal).'},
      {'step': 'Halq or Taqsir', 'desc': 'Shaving or cutting of hair.'},
      {'step': 'Tawaf al-Ifadah', 'desc': 'Circumambulation around the Kaaba.'},
      {'step': 'Sai', 'desc': 'Walking between Safa and Marwa.'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Hajj & Umrah Guide', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (index != steps.length - 1)
                      Container(
                        width: 2,
                        height: 60.h,
                        color: AppColors.secondaryGold.withOpacity(0.3),
                      ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GlassBox(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[index]['step']!, style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(steps[index]['desc']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
                      ],
                    ),
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
