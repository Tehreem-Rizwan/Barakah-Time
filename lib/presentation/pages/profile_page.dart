import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 32.h),
            _buildStatGrid(),
            SizedBox(height: 32.h),
            _buildTierCard(),
            SizedBox(height: 32.h),
            _buildActionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundColor: AppColors.primaryEmerald.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.secondaryGold, size: 60.sp),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(color: AppColors.secondaryGold, shape: BoxShape.circle),
              child: Icon(Icons.camera_alt, color: Colors.black, size: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text('Barakah User', style: TextStyle(color: AppColors.textMain, fontSize: 24.sp, fontWeight: FontWeight.bold)),
        Text('Member since March 2024', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildStatGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Streak', '4 Days', Icons.bolt)),
        SizedBox(width: 16.w),
        Expanded(child: _buildStatItem('Quran', '12 Juz', Icons.menu_book)),
        SizedBox(width: 16.w),
        Expanded(child: _buildStatItem('Points', '1.2k', Icons.stars)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return GlassBox(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondaryGold, size: 20.sp),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _buildTierCard() {
    return GlassBox(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.workspace_premium, color: AppColors.secondaryGold, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Elite Member', style: TextStyle(color: AppColors.textMain, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Text('Top 5% of productive users', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionList() {
    return Column(
      children: [
        _buildActionTile(Icons.history, 'Activity History'),
        _buildActionTile(Icons.bookmark_outline, 'Saved Verses'),
        _buildActionTile(Icons.people_outline, 'Community Badges'),
        _buildActionTile(Icons.logout, 'Sign Out', isDestructive: true),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : AppColors.textMain, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {},
    );
  }
}
