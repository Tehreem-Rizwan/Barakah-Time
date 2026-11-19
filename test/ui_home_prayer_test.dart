import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/spiritual_pulse.dart';
import 'package:barakah_time/domain/repositories/prayer_repository.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:barakah_time/presentation/blocs/location_bloc.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barakah_time/domain/entities/user.dart';
import 'package:barakah_time/presentation/pages/hijri_label.dart';
import 'package:barakah_time/presentation/pages/home_page.dart';
import 'package:barakah_time/presentation/pages/main_navigation_scope.dart';
import 'package:barakah_time/presentation/pages/prayer_times_page.dart';
import 'package:barakah_time/presentation/pages/pulse_page.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _app(Widget home, Locale locale, {double textScale = 1}) =>
    ScreenUtilInit(
      designSize: const Size(390, 844),
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
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
            home: home,
          ),
    );

Future<void> _pump(
  WidgetTester tester,
  Widget home,
  Locale locale, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(home, locale, textScale: textScale));
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

String _countdownText(WidgetTester tester) =>
    tester
        .widget<Text>(
          find.descendant(
            of: find.byType(PrayerCountdown),
            matching: find.byType(Text),
          ),
        )
        .data!;

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
        fajr: d.add(const Duration(hours: 5, minutes: 10)),
        sunrise: d.add(const Duration(hours: 6, minutes: 30)),
        dhuhr: d.add(const Duration(hours: 12, minutes: 5)),
        asr: d.add(const Duration(hours: 15, minutes: 20)),
        maghrib: d.add(const Duration(hours: 17, minutes: 45)),
        isha: d.add(const Duration(hours: 19, minutes: 10)),
      );
    }

    return PrayerTimesEntity(today: day(0), tomorrow: day(1));
  }
}

class _FakePulseRepo implements SpiritualPulseRepository {
  _FakePulseRepo({this.fail = false});
  final bool fail;

  @override
  Future<SpiritualPulseEntity> getPulseData() async {
    if (fail) throw Exception('boom');
    return SpiritualPulseEntity(
      dailyPoints: const [0, 20, 55, 100, 40, 75, 15],
      currentStreak: 4,
      longestStreak: 12,
      totalPoints: 1240,
      recentActivities: [
        SpiritualActivity(
          id: 'a',
          type: 'prayer',
          subType: 'fajr',
          timestamp: DateTime(2026, 11, 15, 5, 20),
          points: 15,
        ),
        SpiritualActivity(
          id: 'b',
          type: 'dhikr',
          timestamp: DateTime(2026, 11, 14, 21),
          points: 10,
        ),
      ],
      badges: const ['first_step', 'streak_7'],
    );
  }

  @override
  Future<bool> logActivity(SpiritualActivity activity) async => true;

  @override
  Future<List<SpiritualActivity>> getActivitiesOn(DateTime day) async => [
    SpiritualActivity(
      id: 'a',
      type: 'prayer',
      subType: 'fajr',
      timestamp: day,
      points: 15,
    ),
  ];
}

class _FakeSaved implements SavedVersesRepository {
  @override
  Future<void> deleteVerse(String id) async {}
  @override
  Future<List<SavedVerse>> getSavedVerses() async => const [];
  @override
  Future<bool> isVerseSaved(String id) async => false;
  @override
  Future<void> saveVerse(SavedVerse verse) async {}
}

Widget _withBlocs(Widget child, {bool pulseFails = false, AuthBloc? auth}) {
  return MultiBlocProvider(
    providers: [
      if (auth != null) BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider(
        create:
            (_) => PrayerBloc(_FakePrayerRepo(), LocationService())..add(
              LoadPrayerTimes(
                const PrayerConfig(
                  method: 'Karachi',
                  madhab: 'shafi',
                  useAutoLocation: false,
                  manualLatitude: 21.42,
                  manualLongitude: 39.82,
                ),
              ),
            ),
      ),
      BlocProvider(
        create:
            (_) => LocationBloc(LocationService())..add(
              UpdateLocationManually(
                latitude: 21.42,
                longitude: 39.82,
                city: 'Makkah',
              ),
            ),
      ),
      BlocProvider(
        create:
            (_) => PulseBloc(
              repository: _FakePulseRepo(fail: pulseFails),
              savedVersesRepository: _FakeSaved(),
            )..add(LoadPulseData()),
      ),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
    await initializeDateFormatting();
  });

  group('PrayerCountdown', () {
    testWidgets('formats the remaining time', (tester) async {
      final now = DateTime(2026, 11, 15, 10);
      await _pump(
        tester,
        Scaffold(
          body: PrayerCountdown(
            target: now.add(const Duration(hours: 1, minutes: 2, seconds: 3)),
            clock: () => now,
          ),
        ),
        const Locale('en'),
      );
      expect(_countdownText(tester), '01:02:03');
    });

    testWidgets('never shows a negative value', (tester) async {
      final now = DateTime(2026, 11, 15, 10);
      await _pump(
        tester,
        Scaffold(
          body: PrayerCountdown(
            target: now.subtract(const Duration(minutes: 5)),
            clock: () => now,
          ),
        ),
        const Locale('en'),
      );
      expect(_countdownText(tester), '00:00:00');
      // Keeps ticking without going negative.
      await tester.pump(const Duration(seconds: 2));
      expect(_countdownText(tester), '00:00:00');
    });
  });

  group('hijri label', () {
    final date = DateTime(2026, 11, 15);
    final hijri = HijriCalendar.fromDate(date);

    test('english uses the package month names', () {
      final previous = HijriCalendar.language;
      HijriCalendar.language = 'en';
      final expected = HijriCalendar.fromDate(date).getLongMonthName();
      HijriCalendar.language = previous;
      final label = hijriDateLabel(date, AppLocalizations(const Locale('en')));
      expect(label, '${hijri.hDay} $expected ${hijri.hYear} AH');
    });

    test('arabic uses arabic month names', () {
      final previous = HijriCalendar.language;
      HijriCalendar.language = 'ar';
      final expected = HijriCalendar.fromDate(date).getLongMonthName();
      HijriCalendar.language = previous;
      final label = hijriDateLabel(date, AppLocalizations(const Locale('ar')));
      expect(label, contains(expected));
      expect(label, endsWith('هـ'));
    });

    test('fa / ur / tr use the l10n month keys', () {
      for (final code in ['fa', 'ur', 'tr']) {
        final l10n = AppLocalizations(Locale(code));
        final month = l10n.translate('hijri_month_${hijri.hMonth}');
        expect(month, isNot('hijri_month_${hijri.hMonth}'));
        expect(
          hijriDateLabel(date, l10n, withYear: false),
          '${hijri.hDay} $month',
        );
      }
      expect(
        hijriMonthName(9, AppLocalizations(const Locale('tr'))),
        'Ramazan',
      );
    });

    test('does not leak the package language globally', () {
      HijriCalendar.language = 'en';
      hijriDateLabel(date, AppLocalizations(const Locale('ar')));
      expect(HijriCalendar.language, 'en');
    });
  });

  group('home helpers', () {
    test('time-of-day greeting', () {
      expect(homeGreetingKey(DateTime(2026, 1, 1, 6)), 'good_morning');
      expect(homeGreetingKey(DateTime(2026, 1, 1, 13)), 'good_afternoon');
      expect(homeGreetingKey(DateTime(2026, 1, 1, 20)), 'good_evening');
      expect(homeGreetingKey(DateTime(2026, 1, 1, 2)), 'good_evening');
    });

    test('first name falls back when unnamed', () {
      const named = UserEntity(id: '1', name: ' Aisha Khan ', email: 'a@b.c');
      const unnamed = UserEntity(id: '2', name: '', email: 'a@b.c');
      expect(homeFirstName(named, 'Fallback'), 'Aisha');
      expect(homeFirstName(unnamed, 'Fallback'), 'Fallback');
    });

    test('every new key is translated in all languages', () {
      const keys = [
        'good_morning',
        'assalamualaikum',
        'qibla_short',
        'calendar_short',
        'more',
        'cardinal_n',
        'qibla_semantics_right',
        'recent_activity',
        'points_this_week',
        'pulse_share_text',
      ];
      for (final code in ['ar', 'fa', 'ur', 'tr']) {
        final l10n = AppLocalizations(Locale(code));
        final en = AppLocalizations(const Locale('en'));
        for (final key in keys) {
          expect(l10n.translate(key), isNot(key));
          if (key != 'pulse_share_text') {
            expect(
              l10n.translate(key),
              isNot(en.translate(key)),
              reason: '$code/$key',
            );
          }
        }
      }
    });
  });

  group('quick actions grid', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('renders 8 actions in ${locale.languageCode}', (
        tester,
      ) async {
        await _pump(
          tester,
          const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: HomeQuickActions(),
            ),
          ),
          locale,
          textScale: 1.3,
        );
        final l10n = AppLocalizations(locale);
        for (final action in HomeQuickAction.values) {
          expect(
            find.text(HomeQuickActions.labelOf(l10n, action)),
            findsOneWidget,
          );
        }
        expect(find.byType(InkWell), findsNWidgets(8));
        // Settings is a tab, not a quick action.
        expect(find.text(l10n.settings), findsNothing);
        // Tiles meet the minimum tap target.
        final size = tester.getSize(find.byType(InkWell).first);
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('weekly bars', () {
    testWidgets('localized labels and per-bar semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        Scaffold(
          body: WeeklyBars(
            points: const [0, 10, 20, 30, 60, 80, 100],
            showValues: true,
            now: DateTime(2026, 11, 15), // a Sunday
          ),
        ),
        const Locale('en'),
        textScale: 1.3,
      );
      expect(find.bySemanticsLabel('Sunday: 100 points'), findsOneWidget);
      expect(find.bySemanticsLabel('Monday: 0 points'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      handle.dispose();
    });
  });

  group('MainNavigationScope', () {
    testWidgets('openTab switches tab inside the scope', (tester) async {
      MainTab? switched;
      await _pump(
        tester,
        MainNavigationScope(
          currentTab: MainTab.home,
          onSwitch: (t) => switched = t,
          child: Builder(
            builder:
                (context) => Scaffold(
                  body: TextButton(
                    onPressed:
                        () => MainNavigationScope.openTab(
                          context,
                          MainTab.pulse,
                          fallback: (_) => const Text('fallback'),
                        ),
                    child: const Text('go'),
                  ),
                ),
          ),
        ),
        const Locale('en'),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(switched, MainTab.pulse);
      expect(find.text('fallback'), findsNothing);
    });

    testWidgets('openTab pushes the fallback outside the scope', (
      tester,
    ) async {
      await _pump(
        tester,
        Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => MainNavigationScope.openTab(
                        context,
                        MainTab.pulse,
                        fallback: (_) => const Scaffold(body: Text('fallback')),
                      ),
                  child: const Text('go'),
                ),
              ),
        ),
        const Locale('en'),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('fallback'), findsOneWidget);
    });
  });

  group('pages at text scale 1.3', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('prayer times page (${locale.languageCode})', (tester) async {
        await _pump(
          tester,
          _withBlocs(const PrayerTimesPage()),
          locale,
          textScale: 1.3,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations(locale);
        expect(find.text(l10n.prayer_times), findsOneWidget);
        expect(find.text(l10n.translate('fajr')), findsOneWidget);
        await tester.pump();
        await tester.pump();
        expect(find.textContaining('Makkah'), findsOneWidget);
        // Countdown never has the stray "- " prefix.
        expect(find.textContaining('- '), findsNothing);
        // Fajr is logged (from the fake repo) -> filled check.
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('pulse page (${locale.languageCode})', (tester) async {
        await _pump(
          tester,
          _withBlocs(const PulsePage()),
          locale,
          textScale: 1.3,
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations(locale);
        expect(find.text(l10n.points_this_week), findsOneWidget);
        expect(find.text('1240'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(l10n.recent_activity),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(l10n.translate('badge_streak_7')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('pulse page error state offers retry', (tester) async {
      await _pump(
        tester,
        _withBlocs(const PulsePage(), pulseFails: true),
        const Locale('en'),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Couldn\'t load your spiritual pulse.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('home page (${locale.languageCode})', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final auth = AuthBloc(
          prefs,
          SupabaseService(idTokenProvider: () async => null),
          FirebaseService(),
        );
        addTearDown(auth.close);
        await _pump(
          tester,
          _withBlocs(const HomePage(), auth: auth),
          locale,
          textScale: 1.3,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        final l10n = AppLocalizations(locale);
        expect(find.text(l10n.assalamualaikum), findsOneWidget);
        expect(find.byType(PrayerCountdown), findsOneWidget);
        expect(find.textContaining('Makkah'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byType(WeeklyBars),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(l10n.translate('motivation_start')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  });
}
