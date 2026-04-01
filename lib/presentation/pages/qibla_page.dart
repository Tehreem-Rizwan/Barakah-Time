import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import 'dart:math' as math;

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Qibla Finder', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassBox(
              width: 300.w,
              height: 300.w,
              shape: BoxShape.circle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryGold.withOpacity(0.3), width: 2),
                    ),
                  ),
                  // Compass Markings
                  ...List.generate(4, (index) {
                    final labels = ['N', 'E', 'S', 'W'];
                    return Transform.rotate(
                      angle: index * (math.pi / 2),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Text(
                            labels[index],
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        ),
                      ),
                    );
                  }),
                  // Qibla Pointer
                  Transform.rotate(
                    angle: 0.5, // Dummy direction
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: AppColors.secondaryGold, size: 40.sp),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                  // Kaaba Icon in center
                  Icon(Icons.mosque, color: Colors.white.withOpacity(0.1), size: 100.sp),
                ],
              ),
            ),
            SizedBox(height: 48.h),
            Text(
              'Qibla Direction',
              style: TextStyle(color: AppColors.textMain, fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              '285° NW from your location',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
            ),
            SizedBox(height: 32.h),
            GlassBox(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: const Text(
                'Point your phone towards the Kaaba',
                style: TextStyle(color: AppColors.secondaryGold, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
