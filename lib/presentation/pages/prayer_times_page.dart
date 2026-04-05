import 'dart:async';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/prayer_bloc.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

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

  String _getLocalizedPrayerName(String name, BuildContext context) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return context.l10n.fajr;
      case 'dhuhr':
        return context.l10n.dhuhr;
      case 'asr':
        return context.l10n.asr;
      case 'maghrib':
        return context.l10n.maghrib;
      case 'isha':
        return context.l10n.isha;
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: Text(context.l10n.prayer_times)),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryGold),
            );
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
                  Icon(
                    Icons.error_outline,
                    color: AppColors.accentRose,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed:
                        () => context.read<PrayerBloc>().add(
                          LoadPrayerTimesWithLocation(),
                        ),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            );
          } else if (state is PrayerInitial) {
            return Center(
              child: Text(
                context.l10n.loading_location,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return const SizedBox.shrink();
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
      case 'Fajr':
        nextPrayerTime = times.fajr;
        break;
      case 'Dhuhr':
        nextPrayerTime = times.dhuhr;
        break;
      case 'Asr':
        nextPrayerTime = times.asr;
        break;
      case 'Maghrib':
        nextPrayerTime = times.maghrib;
        break;
      case 'Isha':
        nextPrayerTime = times.isha;
        break;
      default:
        nextPrayerTime = DateTime.now(); // Should not happen with current logic
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
                    context.l10n.next_prayer,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getLocalizedPrayerName(nextPrayerName, context),
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.access_time,
                color: AppColors.secondaryGold,
                size: 40.sp,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.secondaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.secondaryGold.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '- ',
                  style: TextStyle(
                    color: AppColors.secondaryGold,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
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
              Icon(
                Icons.location_on,
                color: AppColors.secondaryGold,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                context.l10n.current_location,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('EEEE, d MMM').format(DateTime.now()),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
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
      {
        'name': 'Maghrib',
        'time': times.maghrib,
        'icon': Icons.nightlight_round_outlined,
      },
      {'name': 'Isha', 'time': times.isha, 'icon': Icons.nights_stay_outlined},
    ];

    return Column(
      children:
          prayerList.map((prayer) {
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
                        color:
                            isCurrent
                                ? AppColors.secondaryGold.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        prayer['icon'],
                        color:
                            isCurrent
                                ? AppColors.secondaryGold
                                : AppColors.textSecondary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      _getLocalizedPrayerName(prayer['name'], context),
                      style: TextStyle(
                        color:
                            isCurrent
                                ? AppColors.textMain
                                : AppColors.textSecondary,
                        fontSize: 16.sp,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    BlocBuilder<PulseBloc, PulseState>(
                      builder: (context, state) {
                        bool isLogged = false;
                        if (state is PulseLoaded) {
                          // We can't easily check specific subtypes here without updating the entity
                          // but for now, let's just allow logging it.
                          // Ideally, SpiritualPulseEntity would contain a list of today's completed prayers.
                        }

                        return IconButton(
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.secondaryGold.withOpacity(0.5),
                            size: 24.sp,
                          ),
                          onPressed: () {
                            final now = DateTime.now();
                            // Adjust the timestamp to the prayer's scheduled time for consistency
                            final activity = SpiritualActivity(
                              id:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              type: 'prayer',
                              subType: prayer['name'].toString().toLowerCase(),
                              timestamp: DateTime(
                                now.year,
                                now.month,
                                now.day,
                                prayer['time'].hour,
                                prayer['time'].minute,
                              ),
                              points: 15,
                            );
                            context.read<PulseBloc>().add(
                              LogActivity(activity),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_getLocalizedPrayerName(prayer['name'], context)} ${context.l10n.logged_to_pulse}',
                                ),
                                backgroundColor: AppColors.primaryEmerald,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    Text(
                      DateFormat.jm().format(prayer['time']),
                      style: TextStyle(
                        color:
                            isCurrent
                                ? AppColors.secondaryGold
                                : AppColors.textMain,
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
