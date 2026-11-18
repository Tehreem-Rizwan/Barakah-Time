import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/memorial_reminder_service.dart';
import 'package:barakah_time/core/services/ramadan_service.dart';
import 'package:barakah_time/data/repositories/memorial_repository.dart';
import 'package:barakah_time/domain/entities/memorial.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

DailyPrayerTimes _day(DateTime d) {
  DateTime at(int h) => DateTime(d.year, d.month, d.day, h);
  return DailyPrayerTimes(
    date: DateTime(d.year, d.month, d.day),
    fajr: at(5),
    sunrise: at(6),
    dhuhr: at(12),
    asr: at(15),
    maghrib: at(18),
    isha: at(20),
  );
}

void main() {
  final en = AppLocalizations(const Locale('en'));

  group('memorial', () {
    test('codes: generated codes normalize to themselves', () {
      final repo = MemorialRepository(db: () => throw UnimplementedError());
      for (var i = 0; i < 50; i++) {
        final c = repo.newCode();
        expect(c, hasLength(8));
        expect(MemorialRepository.normalizeCode(c), c);
      }
      expect(MemorialRepository.normalizeCode(' abcd-2345 '), 'ABCD2345');
      expect(MemorialRepository.normalizeCode('ABCD0345'), isNull); // 0
      expect(MemorialRepository.normalizeCode('ABC'), isNull);
    });

    test('fromMap reads paras, goals and counts defensively', () {
      final m = Memorial.fromMap('ABCD2345', {
        'ownerUid': 'u1',
        'name': 'Aslam',
        'goals': {'kareema': 125000, 'bad': 'x'},
        'counts': {'kareema': 1000},
        'paras': {
          '1': {'uid': 'u2', 'name': 'Sara', 'done': true},
          '2': {'uid': 'u1', 'name': 'Ali', 'done': false},
          '31': {'uid': 'u3', 'name': 'X', 'done': true},
          '3': 'junk',
        },
        'khatams': 2,
      });
      expect(m.goals, {'kareema': 125000});
      expect(m.counts['kareema'], 1000);
      expect(m.paras.keys, unorderedEquals([1, 2]));
      expect(m.parasDone, 1);
      expect(m.khatams, 2);
      expect(m.isOwner('u1'), isTrue);
      expect(m.isOwner('u2'), isFalse);
      expect(m.showDates, isTrue);
    });

    test('remembrance days count the day of death as day 1', () {
      final death = DateTime(2026, 1, 10);
      final dates = MemorialDate.forDeath(death, DateTime(2026, 1, 11));
      expect(dates[0], MemorialDate('memorial_day3', DateTime(2026, 1, 12)));
      expect(dates[1], MemorialDate('memorial_day10', DateTime(2026, 1, 19)));
      expect(dates[2], MemorialDate('memorial_day40', DateTime(2026, 2, 18)));
      final barsi = dates.last;
      expect(barsi.key, 'memorial_barsi');
      // Same Hijri day and month, one Hijri year later (~354 days).
      final h1 = HijriCalendar.fromDate(death);
      final h2 = HijriCalendar.fromDate(barsi.date);
      expect(h2.hMonth, h1.hMonth);
      expect(h2.hYear, h1.hYear + 1);
      expect(barsi.date.difference(death).inDays, inInclusiveRange(350, 356));
    });

    test('reminders only for future days, at 9 AM, with the name', () {
      final now = DateTime(2026, 1, 12, 10); // after the 3rd-day reminder
      final list = MemorialReminderService.build(
        {
          'ABCD2345': {
            'name': 'Aslam',
            'death': DateTime(2026, 1, 10).toIso8601String(),
          },
        },
        en,
        now,
      );
      expect(list.first.time, DateTime(2026, 1, 19, 9));
      expect(list.first.title, contains('Aslam'));
      expect(list.every((r) => r.time.isAfter(now)), isTrue);
      expect(list, hasLength(3)); // 10th, 40th, Barsi
    });
  });

  group('ramadan', () {
    test('info inside and before Ramadan', () {
      final cal = HijriCalendar();
      final g = cal.hijriToGregorian(1448, 9, 5);
      final inside = RamadanService.infoFor(g, 0);
      expect(inside.isRamadan, isTrue);
      expect(inside.day, 5);
      expect(inside.year, 1448);

      final before = cal.hijriToGregorian(1448, 8, 20);
      final info = RamadanService.infoFor(before, 0);
      expect(info.isRamadan, isFalse);
      expect(info.year, 1448);
      final start = cal.hijriToGregorian(1448, 9, 1);
      expect(
        info.daysUntil,
        DateTime(
          start.year,
          start.month,
          start.day,
        ).difference(DateTime(before.year, before.month, before.day)).inDays,
      );

      // After Ramadan the next one is next Hijri year.
      final after = cal.hijriToGregorian(1448, 11, 1);
      expect(RamadanService.infoFor(after, 0).year, 1449);
    });

    test('moon-sighting adjustment shifts the day', () {
      final g = HijriCalendar().hijriToGregorian(1448, 9, 5);
      expect(RamadanService.infoFor(g, 1).day, 6);
      expect(RamadanService.infoFor(g, -1).day, 4);
    });

    test('log saves, clears and survives bad data', () async {
      SharedPreferences.setMockInitialValues({'ramadan_log': '{oops'});
      final service = RamadanService(await SharedPreferences.getInstance());
      expect(service.loadLog(1448), isEmpty);
      await service.saveDay(
        1448,
        3,
        const FastDay(status: FastStatus.fasted, taraweeh: true),
      );
      await service.saveDay(1448, 4, const FastDay(status: FastStatus.missed));
      expect(service.loadLog(1448)[3]!.taraweeh, isTrue);
      expect(service.loadLog(1448)[4]!.status, FastStatus.missed);
      await service.saveDay(1448, 3, FastDay.empty);
      expect(service.loadLog(1448).keys, [4]);
      expect(service.loadLog(1447), isEmpty);
    });

    test('reminders only on Ramadan days: sehri -30 min and iftar', () {
      final cal = HijriCalendar();
      final lastShaban = cal.hijriToGregorian(1448, 8, 29);
      final days = [
        for (var i = 0; i < 3; i++)
          _day(DateTime(lastShaban.year, lastShaban.month, lastShaban.day + i)),
      ];
      final ramadanDays =
          days.where((d) => HijriCalendar.fromDate(d.date).hMonth == 9).length;
      final list = RamadanService.buildReminders(days, en);
      expect(list, hasLength(ramadanDays * 2));
      final firstRamadan = days.firstWhere(
        (d) => HijriCalendar.fromDate(d.date).hMonth == 9,
      );
      expect(
        list.first.time,
        firstRamadan.fajr.subtract(const Duration(minutes: 30)),
      );
      expect(list[1].time, firstRamadan.maghrib);
    });
  });

  test('every new key exists in all five languages', () {
    const keys = [
      'ramadan_title',
      'ramadan_iftar_dua_meaning',
      'memorial_share_text',
      'memorial_day40',
      'dhikr_kareema',
      'qaza_tracker',
      'promise_no_ads',
      'widget_empty',
    ];
    for (final code in ['en', 'ar', 'fa', 'ur', 'tr']) {
      final l = AppLocalizations(Locale(code));
      for (final k in keys) {
        expect(l.translate(k), isNot(k), reason: '$code/$k');
      }
    }
  });
}
