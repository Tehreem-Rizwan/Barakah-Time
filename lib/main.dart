import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:barakah_time/presentation/blocs/quran_bloc.dart';
import 'package:barakah_time/presentation/pages/home_page.dart';
import 'package:barakah_time/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SakinahApp());
}

class SakinahApp extends StatelessWidget {
  const SakinahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (_) =>
                      di.sl<PrayerBloc>()..add(LoadPrayerTimesWithLocation()),
            ),
            BlocProvider(
              create: (_) => di.sl<PulseBloc>()..add(LoadPulseData()),
            ),
            BlocProvider(create: (_) => di.sl<QuranBloc>()..add(LoadSurahs())),
          ],
          child: MaterialApp(
            title: 'Barakah Time',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}
