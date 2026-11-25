import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/utils/recitations.dart';
import 'package:barakah_time/data/datasources/local/settings_prefs.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prayer times for [day] (Fajr 5:00, sunrise 6:30, Maghrib 17:30, Isha 19:00).
DailyPrayerTimes _times(DateTime day) {
  DateTime at(int h, [int m = 0]) =>
      DateTime(day.year, day.month, day.day, h, m);
  return DailyPrayerTimes(
    date: DateTime(day.year, day.month, day.day),
    fajr: at(5),
    sunrise: at(6, 30),
    dhuhr: at(12),
    asr: at(15),
    maghrib: at(17, 30),
    isha: at(19),
  );
}

// 2026-11-26 is a Thursday, 2026-11-27 a Friday.
final _thu = DateTime(2026, 11, 26);
final _fri = DateTime(2026, 11, 27);
final _sat = DateTime(2026, 11, 28);

List<RecitationWindow> _at(DateTime day, int h, [int m = 0]) =>
    Recitations.activeWindows(
      DateTime(day.year, day.month, day.day, h, m),
      _times(day),
    );

void main() {
  group('active windows', () {
    test('night is from Isha until Fajr', () {
      expect(_at(_sat, 18, 59), isEmpty);
      expect(_at(_sat, 19), [RecitationWindow.night]);
      expect(_at(_sat, 23, 59), [RecitationWindow.night]);
      expect(_at(_sat, 4, 59), [RecitationWindow.night]);
      expect(_at(_sat, 5), isEmpty);
      expect(_at(_sat, 12), isEmpty);
    });

    test('Friday runs from Thursday Maghrib to Friday Maghrib', () {
      expect(_at(_thu, 17, 29), isEmpty);
      expect(_at(_thu, 17, 30), [RecitationWindow.friday]);
      expect(_at(_thu, 21), [RecitationWindow.friday, RecitationWindow.night]);
      expect(_at(_fri, 10), [RecitationWindow.friday]);
      expect(_at(_fri, 17, 29), [RecitationWindow.friday]);
      expect(_at(_fri, 17, 30), isEmpty);
    });

    test('falls back to the clock when prayer times are unknown', () {
      expect(Recitations.activeWindows(DateTime(2026, 11, 28, 22), null), [
        RecitationWindow.night,
      ]);
      expect(
        Recitations.activeWindows(DateTime(2026, 11, 28, 12), null),
        isEmpty,
      );
    });
  });

  group('window keys', () {
    test('a night keeps its key across midnight', () {
      final evening = Recitations.windowKey(
        RecitationWindow.night,
        DateTime(2026, 11, 28, 22),
        _times(_sat),
      );
      final afterMidnight = Recitations.windowKey(
        RecitationWindow.night,
        DateTime(2026, 11, 29, 1),
        _times(DateTime(2026, 11, 29)),
      );
      expect(evening, 'night_20261128');
      expect(afterMidnight, evening);
    });

    test('Thursday evening belongs to the coming Friday', () {
      expect(
        Recitations.windowKey(
          RecitationWindow.friday,
          DateTime(2026, 11, 26, 20),
          _times(_thu),
        ),
        'friday_20261127',
      );
      expect(
        Recitations.windowKey(
          RecitationWindow.friday,
          DateTime(2026, 11, 27, 9),
          _times(_fri),
        ),
        'friday_20261127',
      );
    });
  });

  test('night counts the Sunnah items only; Waqiah/Muzzammil are extra', () {
    final ids = Recitations.nightSunnah.map((r) => r.id).toList();
    expect(ids, [
      'ayat_kursi',
      'baqarah_end',
      'mulk',
      'kafirun',
      'ikhlas',
      'falaq',
      'nas',
    ]);
    expect(Recitations.commonNight.every((r) => !r.sunnah), isTrue);
    expect(Recitations.ayatKursi.surah, 2);
    expect(Recitations.ayatKursi.ayah, 255);
    expect(Recitations.baqarahEnd.ayah, 285);
    expect(Recitations.kahf.surah, 18);
  });

  group('tracker', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('ticks and unticks per window', () async {
      final t = RecitationTracker(await SharedPreferences.getInstance());
      await t.setDone('night_20261128', ['mulk', 'nas'], true);
      expect(t.doneIn('night_20261128'), {'mulk', 'nas'});
      expect(t.doneIn('night_20261129'), isEmpty);
      await t.setDone('night_20261128', ['nas'], false);
      expect(t.isDone('night_20261128', 'nas'), isFalse);
      expect(t.isDone('night_20261128', 'mulk'), isTrue);
    });

    test('keeps only the most recent windows', () async {
      final t = RecitationTracker(await SharedPreferences.getInstance());
      for (var d = 20; d <= 26; d++) {
        await t.setDone('night_202611$d', ['mulk'], true);
      }
      await t.setDone('friday_20261127', ['kahf'], true);
      expect(t.doneIn('night_20261120'), isEmpty);
      expect(t.doneIn('night_20261126'), {'mulk'});
      expect(t.doneIn('friday_20261127'), {'kahf'});
    });

    test('survives corrupted storage', () async {
      SharedPreferences.setMockInitialValues({RecitationTracker.key: 'oops'});
      final t = RecitationTracker(await SharedPreferences.getInstance());
      expect(t.doneIn('night_20261128'), isEmpty);
    });
  });

  group('reminders', () {
    final l10n = AppLocalizations(const Locale('en'));
    final days = [for (var d = 24; d <= 30; d++) _times(DateTime(2026, 11, d))];

    test('off by default: nothing scheduled', () {
      expect(
        Recitations.reminders(days, l10n, night: false, kahf: false),
        isEmpty,
      );
    });

    test(
      'night an hour after Isha; Kahf two hours after sunrise on Friday',
      () {
        final all = Recitations.reminders(days, l10n, night: true, kahf: true);
        final night =
            all.where((r) => r.payload == 'recitation:night').toList();
        final kahf = all.where((r) => r.payload == 'recitation:kahf').toList();
        expect(night.length, 7);
        expect(night.first.time, DateTime(2026, 11, 24, 20));
        expect(kahf.single.time, DateTime(2026, 11, 27, 8, 30));
        expect(kahf.single.body, l10n.kahf_reminder_body);
      },
    );
  });

  group('reminder settings', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('off by default, persisted and synced', () async {
      final prefs = await SharedPreferences.getInstance();
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      addTearDown(bloc.close);
      expect(bloc.state.nightReminder, isFalse);
      expect(bloc.state.kahfReminder, isFalse);

      bloc.add(const ToggleRecitationReminder('kahf', true));
      await bloc.stream.firstWhere((s) => s.kahfReminder);
      expect(prefs.getBool(SettingsPrefs.kahfReminder), isTrue);
      expect(SettingsPrefs.toCloud(prefs)['kahfReminder'], isTrue);

      SharedPreferences.setMockInitialValues({});
      final other = await SharedPreferences.getInstance();
      await SettingsPrefs.applyCloud(other, {'nightReminder': true});
      expect(other.getBool(SettingsPrefs.nightReminder), isTrue);
    });
  });
}
