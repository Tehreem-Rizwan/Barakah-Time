import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/entry_route.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/widgets.dart';
import 'auth/sign_in_page.dart';
import 'main_navigation_page.dart';
import 'onboarding_page.dart';

/// Animated brand splash. Navigates once both the intro animation (~1.2s)
/// and the entry-route resolution have finished.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Length of the intro animation.
  static const Duration animationDuration = Duration(milliseconds: 1200);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashPage.animationDuration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
  );
  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1.0)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
        ),
      );

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final animation = _controller.forward().orCancel.catchError((_) {});
    final firebase =
        GetIt.instance.isRegistered<FirebaseService>()
            ? GetIt.instance<FirebaseService>()
            : null;
    final results = await Future.wait<Object?>([
      animation,
      resolveEntryRoute(firebaseService: firebase),
    ]);
    if (!mounted) return;
    final route = results[1] as AppEntryRoute;
    final Widget page = switch (route) {
      AppEntryRoute.onboarding => const OnboardingPage(),
      AppEntryRoute.signIn => const SignInPage(),
      AppEntryRoute.main => const MainNavigationPage(),
    };
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => page,
        transitionsBuilder:
            (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
        transitionDuration: AppDurations.slow,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      gradientBackground: true,
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Semantics(
                label: l10n.app_name,
                excludeSemantics: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryGold.withValues(alpha: 0.08),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryEmerald.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mosque,
                        size: 80.sp,
                        color: AppColors.secondaryGold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.vXl),
                    Text(
                      l10n.app_name,
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.vSm),
                    Text(
                      l10n.app_tagline,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
