import 'dart:async';
import 'dart:math';
import 'package:barakah_time/presentation/pages/profile_page.dart';
import 'package:barakah_time/presentation/pages/quran_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/daily_ayats.dart';
import '../blocs/prayer_bloc.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/glass_box.dart';
import 'names_all_page.dart';
import 'prayer_times_page.dart';
import 'duas_page.dart';
import 'tools_grid_page.dart';
import 'qibla_page.dart';
import 'zakat_calculator_page.dart';
import 'islamic_calendar_page.dart';
import 'mosque_finder_page.dart';
import 'hajj_guide_page.dart';
import 'tasbeeh_page.dart';
import 'pulse_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Select daily ayat based on date to keep it consistent for the day
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final ayat = dailyAyats[dayOfYear % dailyAyats.length];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00382E), // Deeper Emerald
                    AppColors.backgroundSlate,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assalamualaikum,',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Barakah Time',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.textMain,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              },
                              icon: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        BlocBuilder<PrayerBloc, PrayerState>(
                          builder: (context, state) {
                            if (state is PrayerLoading) {
                              return GlassBox(
                                height: 180.h,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.secondaryGold,
                                  ),
                                ),
                              );
                            }
                            if (state is PrayerLoaded) {
                              return _PrayerTimesCard(
                                prayerTimes: state.prayerTimes,
                              );
                            }
                            if (state is PrayerError) {
                              return GlassBox(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32.w,
                                  vertical: 24.h,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off_outlined,
                                      color: AppColors.secondaryGold
                                          .withOpacity(0.5),
                                      size: 40.sp,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Location Access Required',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Please enable location to see prayer times',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    TextButton(
                                      onPressed:
                                          () => context.read<PrayerBloc>().add(
                                            LoadPrayerTimesWithLocation(),
                                          ),
                                      child: const Text(
                                        'Grant Access & Retry',
                                        style: TextStyle(
                                          color: AppColors.secondaryGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Actions Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Essential Tools',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ToolsGridPage(),
                                ),
                              ),
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.secondaryGold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Action Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.75,
                      children: const [
                        _QuickActionIcon(icon: Icons.mosque, label: 'Prayer'),
                        _QuickActionIcon(icon: Icons.menu_book, label: 'Quran'),
                        _QuickActionIcon(icon: Icons.timer, label: 'Tasbeeh'),
                        _QuickActionIcon(
                          icon: Icons.auto_awesome,
                          label: '99 Names',
                        ),
                        _QuickActionIcon(icon: Icons.explore, label: 'Qibla'),
                        _QuickActionIcon(icon: Icons.bolt, label: 'Pulse'),
                        _QuickActionIcon(icon: Icons.favorite, label: 'Duas'),
                        _QuickActionIcon(
                          icon: Icons.settings,
                          label: 'Settings',
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Ayat Slider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.format_quote,
                                    color: AppColors.secondaryGold,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Daily Ayats',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textMain,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Swipe for more',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 220.h,
                          child: PageView.builder(
                            itemCount: 5, // Show 5 relevant ayats
                            controller: PageController(viewportFraction: 0.9),
                            itemBuilder: (context, index) {
                              final ayat =
                                  dailyAyats[index % dailyAyats.length];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: GlassBox(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share_outlined,
                                              color: AppColors.textSecondary,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              Share.share(
                                                '${ayat.arabic}\n\n${ayat.translation}\n\n${ayat.surah}\n\nBarakah Time ✨',
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(
                                        ayat.arabic,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.secondaryGold,
                                          fontSize: 20.sp,
                                          fontFamily: 'Amiri',
                                          height: 1.6,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        '“${ayat.translation}”',
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14.sp,
                                          color: AppColors.textMain,
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        '- ${ayat.surah}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spiritual Pulse Preview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                    child: const _SpiritualPulseCard(),
                  ),
                ),

                SizedBox(height: 40.h).toSliver(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesCard extends StatefulWidget {
  const _PrayerTimesCard({required this.prayerTimes});
  final dynamic prayerTimes;

  @override
  State<_PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<_PrayerTimesCard> {
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

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayerTimes;

    // Find the actual DateTime for the next prayer for dynamic countdown
    DateTime nextPrayerTime;
    switch (prayer.currentPrayerName) {
      case 'Fajr':
        nextPrayerTime = prayer.fajr;
        break;
      case 'Dhuhr':
        nextPrayerTime = prayer.dhuhr;
        break;
      case 'Asr':
        nextPrayerTime = prayer.asr;
        break;
      case 'Maghrib':
        nextPrayerTime = prayer.maghrib;
        break;
      case 'Isha':
        nextPrayerTime = prayer.isha;
        break;
      default:
        nextPrayerTime = DateTime.now();
    }

    final timeUntil = nextPrayerTime.difference(DateTime.now());
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
        );
      },
      child: GlassBox(
        height: 180.h,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.mosque, size: 200.sp, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${prayer.currentPrayerName} In',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    _formatDuration(timeUntil),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.secondaryGold,
                      letterSpacing: 2,
                      fontSize: 48.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.secondaryGold,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Islamabad, Pakistan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionIcon({required this.icon, required this.label});

  void _handleTap(BuildContext context) {
    switch (label) {
      case '99 Names':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NamesOfAllahPage()),
        );
        break;
      case 'Tasbeeh':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasbeehPage()),
        );
        break;
      case 'Quran':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuranPage()),
        );
        break;
      case 'Pulse':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PulsePage()),
        );
        break;
      case 'Prayer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
        );
        break;
      case 'Duas':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuasPage()),
        );
        break;
      case 'Qibla':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblaPage()),
        );
        break;
      case 'Zakat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZakatCalculatorPage()),
        );
        break;
      case 'Calendar':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IslamicCalendarPage()),
        );
        break;
      case 'Mosques':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MosqueFinderPage()),
        );
        break;
      case 'Hajj Guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HajjGuidePage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label feature coming soon!'),
            backgroundColor: AppColors.cardDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Column(
        children: [
          GlassBox(
            width: 60.w,
            height: 60.h,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryGold.withOpacity(0.15),
                    AppColors.secondaryGold.withOpacity(0.05),
                  ],
                ),
              ),
              child: Icon(icon, color: AppColors.secondaryGold, size: 26.sp),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
              color: AppColors.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpiritualPulseCard extends StatelessWidget {
  const _SpiritualPulseCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        if (state is PulseLoaded) {
          final pulse = state.pulse;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PulsePage()),
              );
            },
            child: GlassBox(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14.w),
                        child: Text(
                          'Spiritual Pulse',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: AppColors.secondaryGold,
                          size: 20,
                        ),
                        onPressed: () => _shareReport(pulse),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final points = pulse.dailyPoints[index];
                        final active = points > 50;
                        return Column(
                          children: [
                            Container(
                              width: 32.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color:
                                    active
                                        ? AppColors.secondaryGold
                                        : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              alignment: Alignment.bottomCenter,
                              child:
                                  active
                                      ? Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.bolt,
                                          color: AppColors.primaryEmerald,
                                          size: 16.sp,
                                        ),
                                      )
                                      : null,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                              style: TextStyle(
                                fontSize: 11.sp,
                                color:
                                    active
                                        ? AppColors.secondaryGold
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Text(
                      pulse.motivationalMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _shareReport(dynamic pulse) {
    final text =
        '✨ My Barakah Report ✨\n\n'
        'I\'m on a ${pulse.currentStreak}-day spiritual streak! 🚀\n'
        '${pulse.motivationalMessage}\n\n'
        'Built with #Sakinah #IslamicApp #Flutter #BarakahTime';
    Share.share(text);
  }
}

extension on Widget {
  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);
}
