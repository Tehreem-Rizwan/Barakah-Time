import 'dart:io';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import 'auth/sign_in_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) return const SignInPage();
        final user = authState.user;

        return Scaffold(
          backgroundColor: AppColors.backgroundSlate,
          appBar: AppBar(
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              children: [
                buildProfileHeader(context, user),
                SizedBox(height: 32.h),
                _buildStatGridContent(context),
                SizedBox(height: 32.h),
                _buildTierCard(),
                SizedBox(height: 32.h),
                _buildActionList(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatGridContent(BuildContext context) {
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        int streak = 0;
        int points = 0;
        if (state is PulseLoaded) {
          streak = state.pulse.currentStreak;
          points =
              state.pulse.dailyPoints.isNotEmpty
                  ? state.pulse.dailyPoints.reduce((a, b) => a + b)
                  : 0;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatItem('Streak', '$streak Days', Icons.bolt),
            ),
            Expanded(child: _buildStatItem('Quran', '2 Juz', Icons.menu_book)),
            Expanded(
              child: _buildStatItem(
                'Points',
                '${(points / 10).toStringAsFixed(1)}k',
                Icons.stars,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: AppColors.primaryEmerald.withOpacity(0.1),
                backgroundImage:
                    user.profilePicPath != null
                        ? FileImage(File(user.profilePicPath!))
                        : null,
                child:
                    user.profilePicPath == null
                        ? Icon(
                          Icons.person,
                          color: AppColors.secondaryGold,
                          size: 60.sp,
                        )
                        : null,
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryGold,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.black, size: 16.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          user.name,
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Member since Oct 2025',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<AuthBloc>().add(UpdateProfileImageRequested(image.path));
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Center(
      child: GlassBox(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondaryGold, size: 20.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: AppColors.secondaryGold,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elite Member',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Top 5% of productive users',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final recentActivities =
            state is PulseLoaded ? state.pulse.recentActivities : [];
        final savedVerses = state is PulseLoaded ? state.savedVerses : [];
        final List<String> badges = state is PulseLoaded ? state.pulse.badges : [];

        return Column(
          children: [
            _buildActionTile(
              Icons.history,
              'Activity History',
              subtitle:
                  recentActivities.isNotEmpty
                      ? 'Last: ${recentActivities.first.type} - ${recentActivities.first.subType ?? ""}'
                      : 'No recent activity',
              onTap:
                  () => _navigateTo(
                    context,
                    ActivityHistoryPage(activities: recentActivities),
                  ),
            ),
            _buildActionTile(
              Icons.bookmark_outline,
              'Saved Verses',
              subtitle: '${savedVerses.length} verses saved',
              onTap:
                  () => _navigateTo(
                    context,
                    SavedVersesPage(verses: savedVerses),
                  ),
            ),
            _buildActionTile(
              Icons.people_outline,
              'Community Badges',
              subtitle: '${badges.length} badges earned',
              onTap: () => _showBadgesDialog(context, badges),
            ),
            _buildActionTile(
              Icons.logout,
              'Sign Out',
              isDestructive: true,
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showBadgesDialog(BuildContext context, List<String> badges) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: const Text(
              'Your Badges',
              style: TextStyle(color: AppColors.textMain),
            ),
            content:
                badges.isEmpty
                    ? const Text(
                      'Keep using the app to earn badges!',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                    : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          badges
                              .map(
                                (badge) => Chip(
                                  label: Text(
                                    badge,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: AppColors.secondaryGold,
                                ),
                              )
                              .toList(),
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.secondaryGold),
                ),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.textMain),
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : AppColors.textMain,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              )
              : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// Sub-pages implementations
class ActivityHistoryPage extends StatelessWidget {
  final List<dynamic> activities;
  const ActivityHistoryPage({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: const Text('Activity History')),
      body:
          activities.isEmpty
              ? const Center(
                child: Text(
                  'No activities yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return GlassBox(
                    padding: EdgeInsets.all(16.w),
                    child: ListTile(
                      leading: Icon(
                        activity.type == 'prayer'
                            ? Icons.mosque
                            : Icons.menu_book,
                        color: AppColors.secondaryGold,
                      ),
                      title: Text(
                        '${activity.type.toUpperCase()} ${activity.subType ?? ""}',
                        style: const TextStyle(color: AppColors.textMain),
                      ),
                      subtitle: Text(
                        activity.timestamp.toString(),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        '+${activity.points} pts',
                        style: const TextStyle(
                          color: AppColors.secondaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class SavedVersesPage extends StatelessWidget {
  final List<dynamic> verses;
  const SavedVersesPage({super.key, required this.verses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: const Text('Saved Verses')),
      body:
          verses.isEmpty
              ? const Center(
                child: Text(
                  'No saved verses.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16.sp),
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  return GlassBox(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${verse.surahName} (${verse.surahNumber}:${verse.ayahNumber})',
                          style: const TextStyle(
                            color: AppColors.secondaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          verse.text,
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (verse.translation != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            verse.translation!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
