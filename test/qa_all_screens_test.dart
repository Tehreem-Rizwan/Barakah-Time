// QA sweep: pumps every screen that can be built without Firebase/network in
// all five locales on a small phone (360x640 logical px) at text scale 1.0
// and 1.3, scrolls every scrollable to the end and opens the main sheets,
// collecting every FlutterError (overflows, render exceptions) along the way.
//
// If the macOS "Arial Unicode" system font is available it is loaded as the
// default family so text has realistic widths (the built-in test font draws
// every glyph as a full em-square, which exaggerates overflows).

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/core/services/app_init_status.dart';
import 'package:barakah_time/core/services/audio_service.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/core/services/ramadan_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/data/repositories/qaza_repository.dart';
import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:barakah_time/data/repositories/tasbeeh_repository.dart';
import 'package:barakah_time/domain/entities/ayah.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/spiritual_pulse.dart';
import 'package:barakah_time/domain/entities/surah.dart';
import 'package:barakah_time/domain/entities/user.dart';
import 'package:barakah_time/domain/repositories/prayer_repository.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:barakah_time/injection_container.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/location_bloc.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:barakah_time/presentation/blocs/quran_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/pages/about_page.dart';
import 'package:barakah_time/presentation/pages/activity_history_page.dart';
import 'package:barakah_time/presentation/pages/auth/sign_in_page.dart';
import 'package:barakah_time/presentation/pages/auth/sign_up_page.dart';
import 'package:barakah_time/presentation/pages/duas_page.dart';
import 'package:barakah_time/presentation/pages/hajj_guide_page.dart';
import 'package:barakah_time/presentation/pages/home_page.dart';
import 'package:barakah_time/presentation/pages/islamic_calendar_page.dart';
import 'package:barakah_time/presentation/pages/memorial_pages.dart';
import 'package:barakah_time/presentation/pages/mosque_finder_page.dart';
import 'package:barakah_time/presentation/pages/names_all_page.dart';
import 'package:barakah_time/presentation/pages/onboarding_page.dart';
import 'package:barakah_time/presentation/pages/prayer_times_page.dart';
import 'package:barakah_time/presentation/pages/profile_page.dart';
import 'package:barakah_time/presentation/pages/pulse_page.dart';
import 'package:barakah_time/presentation/pages/qaza_tracker_page.dart';
import 'package:barakah_time/presentation/pages/qibla_page.dart';
import 'package:barakah_time/presentation/pages/quran_page.dart';
import 'package:barakah_time/presentation/pages/ramadan_page.dart';
import 'package:barakah_time/presentation/pages/saved_verses_page.dart';
import 'package:barakah_time/presentation/pages/settings_page.dart';
import 'package:barakah_time/presentation/pages/surah_detail_page.dart';
import 'package:barakah_time/presentation/pages/tasbeeh_page.dart';
import 'package:barakah_time/presentation/pages/tools_grid_page.dart';
import 'package:barakah_time/presentation/pages/zakat_calculator_page.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeCodes = ['en', 'ar', 'fa', 'ur', 'tr'];
const _scales = [1.0, 1.3];

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

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
  List<SpiritualActivity> _activities() {
    final now = DateTime.now();
    return [
      for (var i = 0; i < 14; i++)
        SpiritualActivity(
          id: 'a$i',
          type: const ['prayer', 'dhikr', 'quran', 'dua'][i % 4],
          subType: i % 4 == 0 ? 'fajr' : null,
          timestamp: now.subtract(Duration(hours: i * 9)),
          points: 10 + i,
        ),
    ];
  }

  @override
  Future<SpiritualPulseEntity> getPulseData() async => SpiritualPulseEntity(
    dailyPoints: const [0, 20, 55, 100, 40, 75, 15],
    currentStreak: 124,
    longestStreak: 365,
    totalPoints: 123456,
    recentActivities: _activities(),
    badges: const ['first_step', 'streak_7'],
  );

  @override
  Future<bool> logActivity(SpiritualActivity activity) async => true;

  @override
  Future<List<SpiritualActivity>> getActivitiesOn(DateTime day) async =>
      _activities();
}

class _FakeSaved implements SavedVersesRepository {
  @override
  Future<void> deleteVerse(String id) async {}
  @override
  Future<List<SavedVerse>> getSavedVerses() async => [
    for (var i = 1; i <= 4; i++)
      SavedVerse(
        id: '2:$i',
        surahNumber: 2,
        ayahNumber: 255 + i,
        text:
            'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
        translation:
            'Allah - there is no deity except Him, the Ever-Living, the '
            'Sustainer of existence. Neither drowsiness overtakes Him nor sleep.',
        surahName: 'Al-Baqara',
        timestamp: DateTime(2026, 11, 10 + i),
      ),
  ];
  @override
  Future<bool> isVerseSaved(String id) async => false;
  @override
  Future<void> saveVerse(SavedVerse verse) async {}
}

class _MemoryCache implements QuranCache {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

Surah _surah(int n, String name, String en, String meaning) => Surah(
  number: n,
  name: name,
  englishName: en,
  englishNameTranslation: meaning,
  numberOfAyahs: 7,
  revelationType: 'Meccan',
);

final _surahs = [
  _surah(1, 'سُورَةُ ٱلْفَاتِحَةِ', 'Al-Faatiha', 'The Opening'),
  _surah(2, 'سُورَةُ البَقَرَةِ', 'Al-Baqara', 'The Cow'),
  _surah(18, 'سُورَةُ الكَهۡفِ', 'Al-Kahf', 'The Cave'),
  _surah(114, 'سُورَةُ النَّاسِ', 'An-Naas', 'Mankind'),
];

class _FakeQuranRepository extends QuranRepository {
  _FakeQuranRepository() : super(cache: _MemoryCache());
  @override
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async => _surahs;

  @override
  Future<List<Ayah>> getSurahWithTranslation(
    int number, {
    String translationEdition = QuranRepository.defaultTranslationEdition,
    bool forceRefresh = false,
  }) async => [
    for (var i = 1; i <= 7; i++)
      Ayah(
        number: i,
        text:
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        translation:
            'In the name of Allah, the Entirely Merciful, the Especially '
            'Merciful. All praise is due to Allah, Lord of the worlds.',
        numberInSurah: i,
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
      ),
  ];
}

class _FakeAudio implements AudioService {
  @override
  AudioStatus get status => AudioStatus.idle;
  @override
  Stream<AudioStatus> get statusStream => Stream.value(AudioStatus.idle);
  @override
  Stream<String> get errorStream => const Stream.empty();
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration?> get durationStream => const Stream.empty();
  @override
  String? get currentMediaId => null;
  @override
  Future<void> stop() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

class _Ctx {
  _Ctx(this.screen, this.locale, this.scale);
  final String screen;
  final String locale;
  final double scale;
  final List<String> errors = [];
  final Set<String> _seen = {};
  String step = 'initial';

  static final _loc = RegExp(
    r'(?:package:barakah_time|file://[^\s]*?/lib)/'
    r'([^\s:]+\.dart):(\d+)(?::\d+)?',
  );

  void record(FlutterErrorDetails d) {
    final text = d.toString();
    final first = d.exceptionAsString().split('\n').first.trim();
    // Prefer the "relevant error-causing widget" location in lib/.
    String where = '?';
    final creatorIdx = text.indexOf('relevant error-causing widget');
    final m =
        creatorIdx >= 0
            ? _loc.firstMatch(text.substring(creatorIdx))
            : _loc.firstMatch(text);
    if (m != null) where = 'lib/${m.group(1)}:${m.group(2)}';
    final key = '$first@$where';
    if (!_seen.add(key)) return;
    final line =
        'QAERR|$screen|$locale|${scale.toStringAsFixed(1)}|$step|$first|$where';
    errors.add(line);
    // ignore: avoid_print
    print(line);
  }
}

enum _Auth { initial, guest, signedIn }

class _SignedInAuthBloc extends AuthBloc {
  _SignedInAuthBloc(SharedPreferences prefs)
    : super(
        prefs,
        SupabaseService(idTokenProvider: () async => null),
        FirebaseService(),
      ) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(
      Authenticated(
        UserEntity(
          id: 'u1',
          name: 'Muhammad Abdullah Al-Rahman Siddiqui',
          email: 'muhammad.abdullah.siddiqui@example.com',
          memberSince: DateTime(2024, 3, 1),
          totalQuranPoints: 98765,
          signInProvider: 'password',
        ),
      ),
    );
  }
}

class _Screen {
  const _Screen(
    this.name,
    this.build, {
    this.interact,
    this.settle,
    this.auth = _Auth.guest,
  });
  final String name;
  final _Auth auth;
  final Widget Function() build;
  final Future<void> Function(WidgetTester, _Ctx, AppLocalizations)? interact;

  /// Extra wait after the first frame (e.g. compass timeout).
  final Duration? settle;
}

late SharedPreferences _prefs;

Future<void> _registerServices() async {
  SharedPreferences.setMockInitialValues({});
  _prefs = await SharedPreferences.getInstance();
  await sl.reset();
  sl.registerSingleton<SharedPreferences>(_prefs);
  sl.registerSingleton<TasbeehRepository>(TasbeehRepository(_prefs));
  sl.registerSingleton<RamadanService>(RamadanService(_prefs));
  sl.registerSingleton<QazaRepository>(QazaRepository(_prefs));
  sl.registerSingleton<QuranRepository>(_FakeQuranRepository());
  sl.registerSingleton<AudioService>(_FakeAudio());
  sl.registerSingleton<LocationService>(LocationService());
  sl.registerSingleton<AdhanService>(AdhanService());
}

Widget _app(Widget home, Locale locale, double scale, _Auth auth) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => SettingsBloc(_prefs, countryCode: 'PK')),
      BlocProvider(
        create:
            (_) => PrayerBloc(_FakePrayerRepo(), LocationService())..add(
              LoadPrayerTimes(
                const PrayerConfig(
                  method: 'Karachi',
                  madhab: 'hanafi',
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
                city: 'Makkah al-Mukarramah',
              ),
            ),
      ),
      BlocProvider(
        create:
            (_) => PulseBloc(
              repository: _FakePulseRepo(),
              savedVersesRepository: _FakeSaved(),
            )..add(LoadPulseData()),
      ),
      BlocProvider(
        create: (_) => QuranBloc(_FakeQuranRepository())..add(LoadSurahs()),
      ),
      BlocProvider(
        create: (_) {
          if (auth == _Auth.signedIn) return _SignedInAuthBloc(_prefs);
          final bloc = AuthBloc(
            _prefs,
            SupabaseService(idTokenProvider: () async => null),
            FirebaseService(),
          );
          if (auth == _Auth.guest) bloc.add(ContinueAsGuest());
          return bloc;
        },
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (_, _) => MaterialApp(
            theme: AppTheme.dark(locale, useGoogleFonts: false),
            locale: locale,
            supportedLocales: [for (final c in _localeCodes) Locale(c)],
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
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
            home: home,
          ),
    ),
  );
}

Future<void> _frames(WidgetTester tester, _Ctx ctx, {int n = 3}) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
  expect(tester.takeException(), isNull); // errors are routed to ctx
}

/// Scrolls every visible scrollable to its end in viewport-sized steps.
Future<void> _scrollAll(WidgetTester tester, _Ctx ctx, String label) async {
  for (var i = 0; i < 16; i++) {
    final finder = find.byType(Scrollable);
    final elements = finder.evaluate().toList();
    if (i >= elements.length) break;
    final element = elements[i] as StatefulElement;
    final state = element.state as ScrollableState;
    var guard = 0;
    while (guard++ < 60) {
      if (!state.mounted) break;
      final pos = state.position;
      if (!pos.hasContentDimensions || !pos.hasPixels) break;
      if (pos.pixels >= pos.maxScrollExtent - 0.5) break;
      final step = math.max(pos.viewportDimension * 0.7, 40.0);
      ctx.step = '$label scroll#$i ${pos.axis.name}';
      pos.jumpTo(math.min(pos.pixels + step, pos.maxScrollExtent));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);
    }
  }
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f, warnIfMissed: false);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

final _screens = <_Screen>[
  _Screen('Home', () => const HomePage()),
  _Screen('PrayerTimes', () => const PrayerTimesPage()),
  _Screen('ToolsGrid', () => const ToolsGridPage()),
  _Screen(
    'QazaTracker',
    () => QazaTrackerPage(repository: sl<QazaRepository>()),
    interact: (tester, ctx, l10n) async {
      ctx.step = 'open estimate sheet';
      await _tap(tester, find.text(l10n.translate('qaza_calculate')).first);
      await _scrollAll(tester, ctx, 'estimate sheet');
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        ctx.step = 'estimate sheet: enter 12 years';
        await tester.enterText(fields.first, '12');
        await tester.pump(const Duration(milliseconds: 200));
        ctx.step = 'estimate sheet: add';
        await _tap(tester, find.text(l10n.translate('qaza_add')).last);
        await tester.pump(const Duration(seconds: 1));
        ctx.step = 'populated list';
        await _scrollAll(tester, ctx, 'populated');
        // Edit-count dialog.
        final edit = find.byIcon(Icons.edit_outlined);
        if (edit.evaluate().isNotEmpty) {
          ctx.step = 'edit count dialog';
          await _tap(tester, edit.first);
        }
      }
    },
  ),
  _Screen(
    'Ramadan',
    () => const RamadanPage(),
    interact: (tester, ctx, l10n) async {
      await tester.scrollUntilVisible(
        find.byType(GridView),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final cells = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(InkWell),
      );
      if (cells.evaluate().isEmpty) {
        throw StateError('no day cells');
      }
      ctx.step = 'open day sheet';
      await _tap(tester, cells.first);
      await _scrollAll(tester, ctx, 'day sheet');
    },
  ),
  _Screen('EsaalESawab(guest)', () => const MemorialsPage()),
  _Screen('Tasbeeh', () => const TasbeehPage()),
  _Screen('Duas', () => const DuasPage()),
  _Screen(
    '99Names',
    () => const NamesOfAllahPage(),
    interact: (tester, ctx, l10n) async {
      ctx.step = 'name details sheet';
      await tester.enterText(find.byType(TextField).first, '99');
      await tester.pump(const Duration(milliseconds: 200));
      await _tap(tester, find.text('As-Sabur').first);
      await _scrollAll(tester, ctx, 'name sheet');
    },
  ),
  _Screen('IslamicCalendar', () => const IslamicCalendarPage()),
  _Screen(
    'Zakat',
    () => const ZakatCalculatorPage(),
    interact: (tester, ctx, l10n) async {
      ctx.step = 'zakat result';
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '123456789');
      await tester.enterText(fields.at(5), '1');
      await tester.pump();
      final button = find.byType(PrimaryButton);
      if (button.evaluate().isNotEmpty) await _tap(tester, button.first);
      await _scrollAll(tester, ctx, 'zakat result');
    },
  ),
  _Screen('HajjGuide', () => const HajjGuidePage()),
  _Screen(
    'Settings',
    () => const SettingsPage(),
    interact: (tester, ctx, l10n) async {
      ctx.step = 'open adjust-times sheet';
      await _tap(tester, find.text(l10n.adjust_times).first);
      final plus = find.byIcon(Icons.add_rounded);
      for (var i = 0; i < 3; i++) {
        await _tap(tester, plus.first);
      }
      await _tap(tester, find.byIcon(Icons.remove_rounded).last);
      await _scrollAll(tester, ctx, 'adjust-times sheet');
      expect(find.text(l10n.minutesShort(3)), findsOneWidget);
      await _tap(tester, find.text(l10n.reset).last);
      await _tap(tester, find.text(l10n.close).last);
    },
  ),
  _Screen('About', () => const AboutPage()),
  _Screen(
    'Onboarding',
    () => const OnboardingPage(),
    interact: (tester, ctx, l10n) async {
      for (var i = 0; i < 3; i++) {
        final next = find.text(l10n.onboarding_next);
        if (next.evaluate().isEmpty) break;
        ctx.step = 'onboarding page ${i + 2}';
        await _tap(tester, next.first);
        await tester.pump(const Duration(seconds: 1));
      }
    },
  ),
  _Screen(
    'SignIn',
    () => const SignInPage(),
    auth: _Auth.initial,
    interact: (tester, ctx, l10n) async {
      ctx.step = 'sign-in validation errors';
      await _tap(tester, find.byType(PrimaryButton).first);
      await _scrollAll(tester, ctx, 'errors');
    },
  ),
  _Screen(
    'SignUp',
    () => const SignUpPage(),
    auth: _Auth.initial,
    interact: (tester, ctx, l10n) async {
      ctx.step = 'sign-up validation errors';
      await _tap(tester, find.byType(PrimaryButton).first);
      await _scrollAll(tester, ctx, 'errors');
    },
  ),
  _Screen('Pulse', () => const PulsePage()),
  _Screen(
    'Qibla(compass)',
    () => const QiblaPage(),
    settle: const Duration(milliseconds: 500),
  ),
  _Screen(
    'Qibla(no sensor)',
    () => const QiblaPage(),
    settle: const Duration(seconds: 4),
  ),
  _Screen('SavedVerses', () => const SavedVersesPage()),
  _Screen('ActivityHistory', () => const ActivityHistoryPage()),
  _Screen('Quran', () => const QuranPage()),
  _Screen('SurahDetail', () => SurahDetailPage(surah: _surahs[1])),
  _Screen('Profile(guest)', () => const ProfilePage()),
  _Screen(
    'Profile(signed in)',
    () => const ProfilePage(),
    auth: _Auth.signedIn,
  ),
  _Screen(
    'Settings(signed in)',
    () => const SettingsPage(),
    auth: _Auth.signedIn,
  ),
  _Screen('Home(signed in)', () => const HomePage(), auth: _Auth.signedIn),
  _Screen('MosqueFinder(no location)', () => const MosqueFinderPage()),
];

Future<void> _runScreen(
  WidgetTester tester,
  _Screen screen,
  String code,
  double scale,
) async {
  final ctx = _Ctx(screen.name, code, scale);
  final locale = Locale(code);
  final l10n = AppLocalizations(locale);
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;

  // Compass: emit a reading for the "compass" variant, nothing otherwise.
  const compass = EventChannel('hemanthraj/flutter_compass');
  tester.binding.defaultBinaryMessenger.setMockStreamHandler(
    compass,
    MockStreamHandler.inline(
      onListen: (args, sink) {
        if (screen.name == 'Qibla(compass)') sink.success(<double>[35, 35, 15]);
      },
    ),
  );

  final original = FlutterError.onError;
  FlutterError.onError = ctx.record;
  try {
    await tester.pumpWidget(_app(screen.build(), locale, scale, screen.auth));
    await _frames(tester, ctx);
    if (screen.settle != null) {
      await tester.pump(screen.settle!);
      await _frames(tester, ctx, n: 1);
    }
    await _scrollAll(tester, ctx, 'page');
    if (screen.interact != null) {
      // Back to the top before interacting.
      for (final e in find.byType(Scrollable).evaluate()) {
        final s = (e as StatefulElement).state as ScrollableState;
        if (s.position.hasPixels) s.position.jumpTo(0);
      }
      await tester.pump();
      try {
        await screen.interact!(tester, ctx, l10n);
      } on TestFailure catch (e) {
        ctx.errors.add(
          'QAHARNESS|${screen.name}|$code|$scale|${ctx.step}|${e.message}',
        );
      } on StateError catch (e) {
        ctx.errors.add('QAHARNESS|${screen.name}|$code|$scale|${ctx.step}|$e');
      }
      await _frames(tester, ctx);
    }
    ctx.step = 'teardown';
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  } finally {
    FlutterError.onError = original;
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(compass, null);
    tester.view.reset();
  }
  expect(ctx.errors, isEmpty, reason: ctx.errors.join('\n'));
}

Future<void> _loadRealFont() async {
  const candidates = [
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    '/Library/Fonts/Arial Unicode.ttf',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    final data = ByteData.view(Uint8List.fromList(bytes).buffer);
    for (final family in ['Roboto', 'MaterialIcons-fallback']) {
      final loader = FontLoader(family)..addFont(Future.value(data));
      await loader.load();
    }
    return;
  }
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
    await initializeDateFormatting();
    PackageInfo.setMockInitialValues(
      appName: 'Barakah Time',
      packageName: 'com.tehreem.barakah_time',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
    await _loadRealFont();
  });

  setUp(() async {
    AppInitStatus.firebaseReady = true;
    await _registerServices();
  });

  tearDown(() async {
    AppInitStatus.reset();
    await sl.reset();
  });

  for (final screen in _screens) {
    group(screen.name, () {
      for (final code in _localeCodes) {
        for (final scale in _scales) {
          testWidgets('$code @ 360x640 x$scale', (tester) async {
            await _runScreen(tester, screen, code, scale);
          });
        }
      }
    });
  }
}
