import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/widgets.dart';

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

    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      title: context.l10n.hajj_guide,
      body: ListView.builder(
        padding: AppSpacing.page,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final isLast = index == steps.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.onGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Connector grows with the step card's height.
                    Expanded(
                      child:
                          isLast
                              ? const SizedBox.shrink()
                              : Container(
                                width: 2,
                                margin: EdgeInsetsDirectional.symmetric(
                                  vertical: AppSpacing.vXs,
                                ),
                                color: AppColors.secondaryGold.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                    ),
                  ],
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: isLast ? 0 : AppSpacing.vLg,
                    ),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index]['step']!,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vSm),
                          Text(
                            steps[index]['desc']!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
