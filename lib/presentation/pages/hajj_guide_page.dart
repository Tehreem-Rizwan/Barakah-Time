import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class HajjGuidePage extends StatelessWidget {
  const HajjGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {
        'step': context.l10n.hajj_step1_title,
        'desc': context.l10n.hajj_step1_desc,
      },
      {
        'step': context.l10n.hajj_step2_title,
        'desc': context.l10n.hajj_step2_desc,
      },
      {
        'step': context.l10n.hajj_step3_title,
        'desc': context.l10n.hajj_step3_desc,
      },
      {
        'step': context.l10n.hajj_step4_title,
        'desc': context.l10n.hajj_step4_desc,
      },
      {
        'step': context.l10n.hajj_step5_title,
        'desc': context.l10n.hajj_step5_desc,
      },
      {
        'step': context.l10n.hajj_step6_title,
        'desc': context.l10n.hajj_step6_desc,
      },
      {
        'step': context.l10n.hajj_step7_title,
        'desc': context.l10n.hajj_step7_desc,
      },
      {
        'step': context.l10n.hajj_step8_title,
        'desc': context.l10n.hajj_step8_desc,
      },
      {
        'step': context.l10n.hajj_step9_title,
        'desc': context.l10n.hajj_step9_desc,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text(
          context.l10n.hajj_guide,
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (index != steps.length - 1)
                      Container(
                        width: 2,
                        height: 60.h,
                        color: AppColors.secondaryGold.withOpacity(0.3),
                      ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GlassBox(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index]['step']!,
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          steps[index]['desc']!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
