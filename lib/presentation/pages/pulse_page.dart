import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class PulsePage extends StatelessWidget {
  const PulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: Text(context.l10n.pulse)),
      body: BlocBuilder<PulseBloc, PulseState>(
        builder: (context, state) {
          if (state is PulseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryGold),
            );
          }
          if (state is PulseLoaded) {
            final pulse = state.pulse;
            return RefreshIndicator(
              onRefresh:
                  () async => context.read<PulseBloc>().add(LoadPulseData()),
              color: AppColors.secondaryGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    _buildInsightCard(pulse.motivationalMessage, context),
                    SizedBox(height: 24.h),
                    _buildWeeklyStats(pulse.dailyPoints, context),
                    SizedBox(height: 24.h),
                    _buildStreakCard(pulse.currentStreak, context),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(
              context.l10n.no_data,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(String message, BuildContext context) {
    return GlassBox(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.secondaryGold,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                context.l10n.spiritual_insight,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(List<int> points, BuildContext context) {
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return GlassBox(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weekly_activity,
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return _Bar(
                day: days[index],
                height:
                    (points[index] * 0.8).h + 20.h, // Scale points to height
                active: points[index] > 50,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryEmerald.withOpacity(0.8),
            AppColors.primaryEmerald,
          ],
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
              Text(
                '$streak ${context.l10n.streak}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${context.l10n.milestone} ${((streak / 7).floor() + 1) * 7} ${context.l10n.days}',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
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
              color:
                  active
                      ? AppColors.secondaryGold
                      : AppColors.secondaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  active
                      ? [
                        BoxShadow(
                          color: AppColors.secondaryGold.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                      : [],
            ),
            child:
                active
                    ? Center(
                      child: Icon(
                        Icons.bolt,
                        color: Colors.black54,
                        size: 14.sp,
                      ),
                    )
                    : null,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          day,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
      ],
    );
  }
}
