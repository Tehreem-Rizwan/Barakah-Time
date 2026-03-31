import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class PulsePage extends StatelessWidget {
  const PulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('Spiritual Pulse', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildInsightCard(),
            SizedBox(height: 24.h),
            _buildWeeklyStats(),
            SizedBox(height: 24.h),
            _buildStreakCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return GlassBox(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.secondaryGold, size: 24.sp),
              SizedBox(width: 12.w),
              Text('Spiritual Insight', style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Your spiritual momentum is up by 15% this week. Keep maintaining your Tahajjud streak!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return GlassBox(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Activity', style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Bar(day: 'M', height: 40.h, active: false),
              _Bar(day: 'T', height: 80.h, active: true),
              _Bar(day: 'W', height: 70.h, active: true),
              _Bar(day: 'T', height: 90.h, active: true),
              _Bar(day: 'F', height: 50.h, active: false),
              _Bar(day: 'S', height: 30.h, active: false),
              _Bar(day: 'S', height: 20.h, active: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryEmerald.withOpacity(0.8), AppColors.primaryEmerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: AppColors.secondaryGold, size: 40.sp),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4 Day Streak!', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Text('Next milestone at 7 days', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double height;
  final bool active;
  const _Bar({required this.day, required this.height, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: 32.w,
            height: height,
            decoration: BoxDecoration(
              color: active ? AppColors.secondaryGold : AppColors.secondaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: active ? [
                BoxShadow(color: AppColors.secondaryGold.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
              ] : [],
            ),
            child: active ? Center(child: Icon(Icons.bolt, color: Colors.black54, size: 14.sp)) : null,
          ),
        ),
        SizedBox(height: 12.h),
        Text(day, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
      ],
    );
  }
}
