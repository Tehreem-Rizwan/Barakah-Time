import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:barakah_time/presentation/blocs/quran_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SpiritualActivityAdapter());
  Hive.registerAdapter(SavedVerseAdapter());

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
            BlocProvider(
              create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
            ),
            BlocProvider(
              create: (_) => di.sl<SettingsBloc>()..add(LoadSettings()),
            ),
          ],
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return MaterialApp(
                title: 'Barakah Time',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                locale: Locale(state.languageCode),
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                  Locale('fa'),
                  Locale('ur'),
                  Locale('tr'),
                ],
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const SplashPage(),
              );
            },
          ),
        );
      },
    );
  }
}
