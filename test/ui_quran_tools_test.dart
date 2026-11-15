import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:barakah_time/data/repositories/tasbeeh_repository.dart';
import 'package:barakah_time/domain/entities/surah.dart';
import 'package:barakah_time/injection_container.dart';
import 'package:barakah_time/presentation/blocs/quran_bloc.dart';
import 'package:barakah_time/presentation/pages/hajj_guide_page.dart';
import 'package:barakah_time/presentation/pages/islamic_calendar_page.dart';
import 'package:barakah_time/presentation/pages/names_all_page.dart';
import 'package:barakah_time/presentation/pages/quran_page.dart';
import 'package:barakah_time/presentation/pages/surah_detail_page.dart';
import 'package:barakah_time/presentation/pages/tasbeeh_page.dart';
import 'package:barakah_time/presentation/pages/zakat_calculator_page.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(
  Widget home, {
  Locale locale = const Locale('en'),
  double scale = 1,
}) => ScreenUtilInit(
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
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
        home: home,
      ),
);

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(1125, 2436),
  Locale locale = const Locale('en'),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(home, locale: locale, scale: scale));
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

Surah _surah(int n, String name, String en, String meaning) => Surah(
  number: n,
  name: name,
  englishName: en,
  englishNameTranslation: meaning,
  numberOfAyahs: 7,
  revelationType: 'Meccan',
);

class _MemoryCache implements QuranCache {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

class _FakeQuranRepository extends QuranRepository {
  _FakeQuranRepository(this.surahs) : super(cache: _MemoryCache());
  final List<Surah> surahs;
  @override
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async => surahs;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
  });

  group('TasbeehProgress', () {
    test('rounds and in-round count', () {
      expect(const TasbeehProgress(0, 33).inRound, 0);
      expect(const TasbeehProgress(0, 33).round, 1);
      expect(const TasbeehProgress(1, 33).inRound, 1);
      expect(const TasbeehProgress(33, 33).inRound, 33);
      expect(const TasbeehProgress(33, 33).fraction, 1.0);
      expect(const TasbeehProgress(33, 33).round, 1);
      expect(const TasbeehProgress(34, 33).inRound, 1);
      expect(const TasbeehProgress(34, 33).round, 2);
      expect(const TasbeehProgress(99, 33).completedRounds, 3);
    });

    test('target reached only on multiples', () {
      expect(const TasbeehProgress(0, 33).isTargetReached, isFalse);
      expect(const TasbeehProgress(33, 33).isTargetReached, isTrue);
      expect(const TasbeehProgress(66, 33).isTargetReached, isTrue);
      expect(const TasbeehProgress(67, 33).isTargetReached, isFalse);
      expect(const TasbeehProgress(100, 100).isTargetReached, isTrue);
    });

    test('invalid target is clamped to 1', () {
      expect(const TasbeehProgress(5, 0).target, 1);
      expect(const TasbeehProgress(5, 0).isTargetReached, isTrue);
    });
  });

  group('Quran helpers', () {
    final surahs = [
      _surah(1, 'سُورَةُ ٱلْفَاتِحَةِ', 'Al-Faatiha', 'The Opening'),
      _surah(2, 'سُورَةُ البَقَرَةِ', 'Al-Baqara', 'The Cow'),
      _surah(112, 'سُورَةُ الإِخۡلَاصِ', 'Al-Ikhlaas', 'Sincerity'),
    ];

    test('filterSurahs by number, English name, meaning and Arabic', () {
      expect(filterSurahs(surahs, '').length, 3);
      expect(filterSurahs(surahs, '112').single.number, 112);
      expect(filterSurahs(surahs, 'baqara').single.number, 2);
      expect(filterSurahs(surahs, 'al baqara').single.number, 2);
      expect(filterSurahs(surahs, 'cow').single.number, 2);
      expect(filterSurahs(surahs, 'الفاتحة').single.number, 1);
      expect(filterSurahs(surahs, 'zzz'), isEmpty);
    });

    test('translation language and direction from edition', () {
      expect(translationLanguageOf('en.asad'), 'en');
      expect(translationLanguageOf('ur.jalandhry'), 'ur');
      expect(translationLanguageOf('ar.muyassar'), 'ar');
      expect(isLtrLanguage('en'), isTrue);
      expect(isLtrLanguage('tr'), isTrue);
      expect(isLtrLanguage('ur'), isFalse);
      expect(isLtrLanguage('fa'), isFalse);
      expect(isLtrLanguage('ar'), isFalse);
    });
  });

  group('Last read', () {
    tearDown(() => sl.reset());

    test('saves and loads surah/ayah', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sl.registerSingleton<SharedPreferences>(prefs);
      expect(QuranLastRead.load(), isNull);
      await QuranLastRead.save(18, 10);
      final r = QuranLastRead.load()!;
      expect(r.surah, 18);
      expect(r.ayah, 10);
      expect(prefs.getInt('last_read_surah'), 18);
      expect(prefs.getInt('last_read_ayah'), 10);
    });
  });

  group('quran page', () {
    final surahs = [
      _surah(1, 'سُورَةُ ٱلْفَاتِحَةِ', 'Al-Faatiha', 'The Opening'),
      _surah(2, 'سُورَةُ البَقَرَةِ', 'Al-Baqara', 'The Cow'),
      _surah(18, 'سُورَةُ الكَهۡفِ', 'Al-Kahf', 'The Cave'),
    ];

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'last_read_surah': 18,
        'last_read_ayah': 10,
      });
      sl.registerSingleton<SharedPreferences>(
        await SharedPreferences.getInstance(),
      );
    });

    tearDown(() => sl.reset());

    testWidgets('search filters and continue reading card shows', (
      tester,
    ) async {
      final bloc = QuranBloc(_FakeQuranRepository(surahs))..add(LoadSurahs());
      addTearDown(bloc.close);
      await _pump(
        tester,
        BlocProvider.value(value: bloc, child: const QuranPage()),
        scale: 1.3,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Continue reading'), findsOneWidget);
      expect(find.text('Al-Kahf • Ayah 10'), findsOneWidget);
      expect(find.text('Al-Baqara'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'cow');
      await tester.pump();
      expect(find.text('Al-Baqara'), findsOneWidget);
      expect(find.text('Al-Faatiha'), findsNothing);
      expect(find.text('Continue reading'), findsNothing);

      await tester.enterText(find.byType(TextField), 'nothing here');
      await tester.pump();
      expect(find.text('No surahs match your search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('HijriMonthGrid is a valid 7-column month', () {
    for (final first in [0, 1, 6]) {
      final g = HijriMonthGrid.forDate(DateTime(2026, 11, 15), first);
      expect(g.daysInMonth, inInclusiveRange(29, 30));
      expect(g.leadingBlanks, inInclusiveRange(0, 6));
      expect(g.todayDay, inInclusiveRange(1, 30));
    }
  });

  group('names', () {
    test('search by number keeps real number', () {
      final r = filterNames(kNumberedNames, '99');
      expect(r.single.name, 'As-Sabur');
      expect(r.single.number, 99);
      expect(filterNames(kNumberedNames, 'rahman').first.number, 1);
      expect(filterNames(kNumberedNames, 'الرحيم').single.number, 2);
    });

    testWidgets('number search shows the card and details sheet', (
      tester,
    ) async {
      await _pump(tester, const NamesOfAllahPage(), scale: 1.3);
      await tester.enterText(find.byType(TextField), '99');
      await tester.pump();
      expect(find.text('As-Sabur'), findsOneWidget);
      await tester.tap(find.text('As-Sabur'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Name 99 of 99'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('zakat', () {
    testWidgets('shows placeholder until calculated', (tester) async {
      await _pump(tester, const ZakatCalculatorPage());
      expect(find.text(kZakatPlaceholder), findsOneWidget);
      expect(find.text('0.00'), findsNothing);

      await tester.enterText(find.byType(TextField).at(0), '100000');
      await tester.enterText(find.byType(TextField).at(5), '1');
      await tester.ensureVisible(find.text('Calculate Zakat'));
      await tester.tap(find.text('Calculate Zakat'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(kZakatPlaceholder), findsNothing);
      expect(find.text('2,500.00'), findsOneWidget);
    });
  });

  group('tasbeeh page', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      sl.registerSingleton<SharedPreferences>(prefs);
      sl.registerSingleton<TasbeehRepository>(TasbeehRepository(prefs));
    });

    tearDown(() => sl.reset());

    testWidgets('tap counts, persists and shows progress', (tester) async {
      await _pump(tester, const TasbeehPage());
      final counter = find.bySemanticsLabel(RegExp('Counter: 0 / 33'));
      expect(counter, findsOneWidget);
      await tester.tap(counter);
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(RegExp('Counter: 1 / 33')));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Counter: 2 / 33')), findsOneWidget);
      expect(sl<TasbeehRepository>().load().count, 2);

      await tester.tap(find.text('99'));
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Counter: 2 / 99')), findsOneWidget);
    });

    testWidgets('no overflow in landscape at text scale 1.3', (tester) async {
      await _pump(
        tester,
        const TasbeehPage(),
        size: const Size(2436, 1125),
        scale: 1.3,
      );
      await _pump(
        tester,
        const TasbeehPage(),
        size: const Size(960, 1600),
        locale: const Locale('ar'),
        scale: 1.3,
      );
    });
  });

  group('static pages render without overflow', () {
    for (final locale in const [Locale('en'), Locale('ar'), Locale('ur')]) {
      testWidgets('calendar + hajj (${locale.languageCode})', (tester) async {
        await _pump(
          tester,
          const IslamicCalendarPage(),
          locale: locale,
          scale: 1.3,
        );
        await _pump(tester, const HajjGuidePage(), locale: locale, scale: 1.3);
      });
    }
  });
}
