import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildProfileTile(),
          SizedBox(height: 32.h),
          _buildSection('App Settings'),
          _buildSettingTile(Icons.notifications_none, 'Notifications', 'Adhan, reminders & alerts'),
          _buildSettingTile(Icons.location_on_outlined, 'Location', 'Manual or GPS detection'),
          _buildSettingTile(Icons.language, 'Language', 'English (United States)'),
          SizedBox(height: 32.h),
          _buildSection('Preferences'),
          _buildSettingTile(Icons.mosque_outlined, 'Calculation Method', 'Karachi (Hanafi)'),
          _buildSettingTile(Icons.format_size, 'Quran Font Size', 'Large (24)'),
          SizedBox(height: 32.h),
          _buildSection('Support'),
          _buildSettingTile(Icons.star_outline, 'Rate us', 'Support our work'),
          _buildSettingTile(Icons.info_outline, 'About', 'Version 1.0.0'),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return GlassBox(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primaryEmerald.withOpacity(0.2),
            child: Icon(Icons.person, color: AppColors.secondaryGold, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barakah User', style: TextStyle(color: AppColors.textMain, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Text('barakah.pro@email.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
            ],
          ),
          const Spacer(),
          Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: AppColors.secondaryGold, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: GlassBox(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textMain, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textMain, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
