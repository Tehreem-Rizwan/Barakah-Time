import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('Digital Tasbeeh', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SubhanAllah',
              style: TextStyle(color: AppColors.textMain, fontSize: 24.sp, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            SizedBox(height: 60.h),
            GestureDetector(
              onTap: () => setState(() => _counter++),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                    width: 240.w,
                    height: 240.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryGold.withOpacity(0.2), width: 4),
                      boxShadow: [
                        BoxShadow(color: AppColors.secondaryGold.withOpacity(0.1), blurRadius: 40, spreadRadius: 10),
                      ],
                    ),
                  ),
                  GlassBox(
                    width: 200.w,
                    height: 200.w,
                    borderRadius: BorderRadius.circular(100),
                    child: Center(
                      child: Text(
                        '$_counter',
                        style: TextStyle(color: AppColors.secondaryGold, fontSize: 60.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.textSecondary, size: 30.sp),
                  onPressed: () => setState(() => _counter = 0),
                ),
                SizedBox(width: 40.w),
                Text('Tap the circle to count', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
