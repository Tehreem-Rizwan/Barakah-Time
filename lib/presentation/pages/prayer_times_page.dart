import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/prayer_bloc.dart';
import '../widgets/glass_box.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('Prayer Times', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondaryGold));
          } else if (state is PrayerLoaded) {
            final times = state.prayerTimes;
            final now = DateTime.now();
            
            // Re-calculate time until next prayer if it's lagging
            // Actually, the entity already has it, but for a live countdown, we should check it.
            // For now, let's assume the entity is updated or we use the timer to refresh UI.
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        _buildCurrentPrayerCard(times),
                        SizedBox(height: 24.h),
                        _buildPrayerTimesList(times),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is PrayerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.accentRose, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => context.read<PrayerBloc>().add(LoadPrayerTimesWithLocation()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Loading location...', style: TextStyle(color: AppColors.textSecondary)));
        },
      ),
    );
  }

  Widget _buildCurrentPrayerCard(dynamic times) {
    // Determine which prayer is next for the countdown
    final nextPrayerName = times.currentPrayerName;
    
    // Find the actual DateTime for the next prayer to calculate dynamic duration
    DateTime nextPrayerTime;
    switch (nextPrayerName) {
      case 'Fajr': nextPrayerTime = times.fajr; break;
      case 'Dhuhr': nextPrayerTime = times.dhuhr; break;
      case 'Asr': nextPrayerTime = times.asr; break;
      case 'Maghrib': nextPrayerTime = times.maghrib; break;
      case 'Isha': nextPrayerTime = times.isha; break;
      default: nextPrayerTime = DateTime.now(); // Should not happen with current logic
    }
    
    // If the time is in the past (e.g., just after Isha), it refers to tomorrow's Fajr
    // The AdhanService already handles this by providing tomorrow's Fajr in the entity if needed.
    
    final timeUntil = nextPrayerTime.difference(DateTime.now());

    return GlassBox(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Prayer',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    nextPrayerName,
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.access_time, color: AppColors.secondaryGold, size: 40.sp),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.secondaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.secondaryGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '- ',
                  style: TextStyle(color: AppColors.secondaryGold, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDuration(timeUntil),
                  style: TextStyle(
                    color: AppColors.secondaryGold,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.secondaryGold, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'Current Location', // This could be more dynamic if we had the city name
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
              ),
              const Spacer(),
              Text(
                DateFormat('EEEE, d MMM').format(DateTime.now()),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(dynamic times) {
    final List<Map<String, dynamic>> prayerList = [
      {'name': 'Fajr', 'time': times.fajr, 'icon': Icons.wb_twilight_outlined},
      {'name': 'Dhuhr', 'time': times.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': times.asr, 'icon': Icons.wb_cloudy_outlined},
      {'name': 'Maghrib', 'time': times.maghrib, 'icon': Icons.nightlight_round_outlined},
      {'name': 'Isha', 'time': times.isha, 'icon': Icons.nights_stay_outlined},
    ];

    return Column(
      children: prayerList.map((prayer) {
        final bool isCurrent = prayer['name'] == times.currentPrayerName;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: GlassBox(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.secondaryGold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    prayer['icon'],
                    color: isCurrent ? AppColors.secondaryGold : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  prayer['name'],
                  style: TextStyle(
                    color: isCurrent ? AppColors.textMain : AppColors.textSecondary,
                    fontSize: 16.sp,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.jm().format(prayer['time']),
                  style: TextStyle(
                    color: isCurrent ? AppColors.secondaryGold : AppColors.textMain,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
