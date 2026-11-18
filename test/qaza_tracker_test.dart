import 'dart:convert';

import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/user_data_sync_service.dart';
import 'package:barakah_time/data/datasources/local/local_store.dart';
import 'package:barakah_time/data/repositories/qaza_repository.dart';
import 'package:barakah_time/domain/entities/qaza_state.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/presentation/pages/qaza_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Sync implements UserDataSync {
  final pushed = <Map<String, dynamic>>[];
  @override
  String? currentUid = 'u1';
  @override
  void pushQaza(Map<String, dynamic> data) => pushed.add(data);
  @override
  void pushRamadanLog(Map<String, dynamic> log) {}
  @override
  void pushActivity(SpiritualActivity a, {int? longestStreak}) {}
  @override
  void pushBadges(Map<String, DateTime> badges) {}
  @override
  void pushSavedVerse(SavedVerse verse) {}
  @override
  void deleteSavedVerse(String localId) {}
  @override
  void pushSettings(Map<String, dynamic> settings) {}
  @override
  void pushTasbeeh(int count, int loggedCount) {}
}

void main() {
  group('QazaState', () {
    test('estimate adds days to every prayer, Witr optional', () {
      final days = QazaState.daysFor(years: 2, months: 1, days: 5);
      expect(days, 2 * 365 + 30 + 5);
      final withWitr = QazaState.empty.addDays(days);
      expect(withWitr.remainingOf('fajr'), days);
      expect(withWitr.remainingOf('witr'), days);
      expect(withWitr.totalRemaining, days * 6);

      final noWitr = QazaState.empty.addDays(10, includeWitr: false);
      expect(noWitr.remainingOf('isha'), 10);
      expect(noWitr.remainingOf('witr'), 0);
    });

    test('made up moves one from remaining to done; undo reverts', () {
      final s = QazaState.empty.addDays(2).madeUp('asr');
      expect(s.remainingOf('asr'), 1);
      expect(s.doneOf('asr'), 1);
      expect(s.progress, closeTo(1 / 12, 1e-9));
      expect(s.undoMadeUp('asr'), QazaState.empty.addDays(2));
    });

    test('never goes negative and clamps huge values', () {
      expect(QazaState.empty.madeUp('fajr'), QazaState.empty);
      expect(QazaState.empty.undoMadeUp('fajr'), QazaState.empty);
      expect(
        QazaState.empty.withRemaining('fajr', 10000000).remainingOf('fajr'),
        QazaState.maxPerPrayer,
      );
      expect(QazaState.empty.withRemaining('fajr', -4).remainingOf('fajr'), 0);
    });

    test('json round trip ignores junk', () {
      final s = QazaState.empty.addDays(3).madeUp('isha');
      expect(QazaState.fromJson(s.toJson()), s);
      expect(
        QazaState.fromJson({
          'remaining': 'x',
          'done': {'fajr': 'y'},
        }),
        QazaState.empty,
      );
      expect(QazaState.fromJson(null).isEmpty, isTrue);
    });
  });

  group('QazaRepository', () {
    test('saves locally at once and syncs debounced', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sync = _Sync();
      final repo = QazaRepository(prefs, sync: sync, debounce: Duration.zero);

      final s = QazaState.empty.addDays(5);
      await repo.save(s);
      expect(repo.load(), s);
      expect(jsonDecode(prefs.getString(UserPrefsKeys.qaza)!), isA<Map>());

      repo.flush();
      expect(sync.pushed.single, s.toJson());
    });

    test('corrupt local data loads as empty', () async {
      SharedPreferences.setMockInitialValues({UserPrefsKeys.qaza: '{bad'});
      final prefs = await SharedPreferences.getInstance();
      expect(QazaRepository(prefs).load(), QazaState.empty);
    });
  });

  testWidgets('estimate, then mark one made up', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = QazaRepository(prefs);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, __) => MaterialApp(
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: QazaTrackerPage(repository: repo),
            ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Estimate missed prayers'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Days'), '3');
    await tester.pumpAndSettle();
    expect(find.text('Adds 3 of each prayer'), findsOneWidget);
    await tester.tap(find.text('Add to tracker'));
    await tester.pumpAndSettle();

    expect(find.text('18'), findsOneWidget); // 3 days x 6 prayers
    await tester.tap(find.byTooltip('Prayed one qaza: Fajr'));
    await tester.pump();
    expect(find.text('17'), findsOneWidget);
    expect(repo.load().doneOf('fajr'), 1);
  });
}
