import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

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
      appBar: AppBar(title: Text(context.l10n.tasbeeh)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.subhanallah,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
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
                      border: Border.all(
                        color: AppColors.secondaryGold.withOpacity(0.2),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryGold.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
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
                        style: TextStyle(
                          color: AppColors.secondaryGold,
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.textSecondary,
                    size: 30.sp,
                  ),
                  onPressed: () {
                    if (_counter >= 33) {
                      // Log activity if they did at least one set
                      final activity = SpiritualActivity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: 'dhikr',
                        timestamp: DateTime.now(),
                        points:
                            (_counter / 33).floor() *
                            5, // 5 points per set of 33
                      );
                      context.read<PulseBloc>().add(LogActivity(activity));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$_counter ${context.l10n.tasbeeh_dhikr_logged}',
                          ),
                          backgroundColor: AppColors.primaryEmerald,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    setState(() => _counter = 0);
                  },
                ),
                SizedBox(width: 40.w),
                Text(
                  context.l10n.tasbeeh_tap_hint,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
