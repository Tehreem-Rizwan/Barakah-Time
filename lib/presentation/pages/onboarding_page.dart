import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/app_init_status.dart';
import '../../core/services/entry_route.dart';
import '../widgets/widgets.dart';
import 'auth/sign_in_page.dart';
import 'main_navigation_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _finishing = false;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingData> _pages(AppLocalizations l10n) => [
    OnboardingData(
      title: l10n.onboarding_pulse_title,
      description: l10n.onboarding_pulse_desc,
      icon: Icons.bolt,
    ),
    OnboardingData(
      title: l10n.onboarding_prayer_title,
      description: l10n.onboarding_prayer_desc,
      icon: Icons.mosque,
    ),
    OnboardingData(
      title: l10n.onboarding_inspiration_title,
      description: l10n.onboarding_inspiration_desc,
      icon: Icons.auto_awesome,
    ),
  ];

  /// Marks onboarding as seen (read by `resolveEntryRoute`) and moves on:
  /// to Sign In, or straight into the app when sign-in is unavailable.
  Future<void> _finishOnboarding() async {
    if (_finishing) return;
    _finishing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(EntryPrefsKeys.hasSeenOnboarding, true);
    } catch (_) {
      // Non-fatal: worst case onboarding is shown again next launch.
    }
    if (!mounted) return;
    final Widget next =
        AppInitStatus.firebaseReady
            ? const SignInPage()
            : const MainNavigationPage();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
  }

  void _next() {
    if (_currentPage == _pageCount - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: AppDurations.slow,
        curve: AppDurations.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = _pages(l10n);
    final isLast = _currentPage == pages.length - 1;

    return AppScaffold(
      gradientBackground: true,
      body: Column(
        children: [
          // Fixed-height row so the layout doesn't jump on the last page.
          SizedBox(
            height: AppSizes.minTapTarget,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  isLast
                      ? null
                      : Padding(
                        padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                        child: TextButton(
                          onPressed: _finishOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: Text(l10n.skip),
                        ),
                      ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: pages.length,
              itemBuilder:
                  (context, index) => _OnboardingBody(data: pages[index]),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.vMd,
              AppSpacing.xl,
              AppSpacing.vXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: '${_currentPage + 1} / ${pages.length}',
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < pages.length; i++)
                          _Indicator(isActive: _currentPage == i),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.vXl),
                PrimaryButton(
                  label:
                      isLast
                          ? l10n.onboarding_get_started
                          : l10n.onboarding_next,
                  icon: isLast ? null : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Shrink the illustration on short screens / landscape.
        final circle = math.max(
          72.0,
          math.min(200.w, constraints.maxHeight * 0.4),
        );
        return SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.vLg,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(
                0,
                constraints.maxHeight - 2 * AppSpacing.vLg,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGold.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryGold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    data.icon,
                    size: circle * 0.5,
                    color: AppColors.secondaryGold,
                  ),
                ),
                SizedBox(height: AppSpacing.vXxl),
                Semantics(
                  header: true,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.vLg),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  final bool isActive;
  const _Indicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.medium,
      margin: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs),
      height: 8.r,
      width: isActive ? 24.r : 8.r,
      decoration: BoxDecoration(
        color:
            isActive
                ? AppColors.secondaryGold
                : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: AppRadius.pillAll,
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
