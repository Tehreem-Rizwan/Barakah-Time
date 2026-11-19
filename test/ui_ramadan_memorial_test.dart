import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/core/services/ramadan_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:barakah_time/domain/repositories/prayer_repository.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/presentation/pages/memorial_pages.dart';
import 'package:barakah_time/presentation/pages/ramadan_page.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePrayerRepo implements PrayerRepository {
  @override
  Future<PrayerTimesEntity> getPrayerTimes(
    double latitude,
    double longitude, {
    String method = 'Karachi',
    String? madhab,
    Map<String, int> offsets = const {},
  }) async {
    final now = DateTime.now();
    DailyPrayerTimes day(int offset) {
      final d = DateTime(now.year, now.month, now.day + offset);
      return DailyPrayerTimes(
        date: d,
        fajr: d.add(const Duration(hours: 5)),
        sunrise: d.add(const Duration(hours: 6)),
        dhuhr: d.add(const Duration(hours: 12)),
        asr: d.add(const Duration(hours: 15)),
        maghrib: d.add(const Duration(hours: 18)),
        isha: d.add(const Duration(hours: 20)),
      );
    }

    return PrayerTimesEntity(today: day(0), tomorrow: day(1));
  }
}

Future<void> _pump(WidgetTester tester, Widget home, Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => PrayerBloc(_FakePrayerRepo(), LocationService())..add(
                LoadPrayerTimes(
                  const PrayerConfig(
                    method: 'Karachi',
                    madhab: 'hanafi',
                    useAutoLocation: false,
                    manualLatitude: 24.86,
                    manualLongitude: 67.0,
                  ),
                ),
              ),
        ),
        BlocProvider(create: (_) => SettingsBloc(prefs)),
        BlocProvider(
          create:
              (_) => AuthBloc(
                prefs,
                SupabaseService(idTokenProvider: () async => null),
                FirebaseService(),
              ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, _) => MaterialApp(
              theme: AppTheme.dark(locale, useGoogleFonts: false),
              locale: locale,
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
              home: home,
            ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
    await initializeDateFormatting();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sl = GetIt.instance;
    if (sl.isRegistered<RamadanService>()) sl.unregister<RamadanService>();
    sl.registerSingleton(RamadanService(prefs));
  });

  for (final code in ['en', 'ur']) {
    testWidgets('Ramadan page renders and logs a fast ($code)', (tester) async {
      final l10n = AppLocalizations(Locale(code));
      await _pump(tester, const RamadanPage(), Locale(code));
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.translate('ramadan_sehri_ends')), findsWidgets);

      final dayOne = find.descendant(
        of: find.byType(GridView),
        matching: find.text('1'),
      );
      await tester.scrollUntilVisible(
        dayOne,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(dayOne);
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<FastStatus>), findsOneWidget);
      await tester.tap(find.text(l10n.translate('ramadan_fasted')).last);
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final year = GetIt.instance<RamadanService>().logYear(DateTime.now());
      expect(
        GetIt.instance<RamadanService>().loadLog(year)[1]?.status,
        FastStatus.fasted,
      );
    });

    testWidgets('Esaal-e-Sawab asks guests to sign in ($code)', (tester) async {
      final l10n = AppLocalizations(Locale(code));
      await _pump(tester, const MemorialsPage(), Locale(code));
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.translate('memorial_sign_in')), findsOneWidget);
    });
  }
}
