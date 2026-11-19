import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:flutter_test/flutter_test.dart';

DailyPrayerTimes _day(DateTime d) => DailyPrayerTimes(
  date: DateTime(d.year, d.month, d.day),
  fajr: DateTime(d.year, d.month, d.day, 5, 0),
  sunrise: DateTime(d.year, d.month, d.day, 6, 30),
  dhuhr: DateTime(d.year, d.month, d.day, 12, 15),
  asr: DateTime(d.year, d.month, d.day, 15, 45),
  maghrib: DateTime(d.year, d.month, d.day, 18, 0),
  isha: DateTime(d.year, d.month, d.day, 19, 30),
);

void main() {
  final today = DateTime(2026, 11, 14);
  final times = PrayerTimesEntity(
    today: _day(today),
    tomorrow: _day(DateTime(2026, 11, 15)),
  );
  DateTime at(int h, int m) => DateTime(2026, 11, 14, h, m);

  group('nextPrayerAt', () {
    test('before Fajr -> Fajr today', () {
      final n = times.nextPrayerAt(at(3, 0));
      expect(n.prayer, PrayerName.fajr);
      expect(n.isTomorrow, isFalse);
      expect(n.timeUntil(at(3, 0)), const Duration(hours: 2));
    });

    test('between Fajr and sunrise -> Dhuhr (sunrise is skipped)', () {
      final n = times.nextPrayerAt(at(6, 0));
      expect(n.prayer, PrayerName.dhuhr);
      expect(n.time, times.dhuhr);
      expect(times.currentPrayerAt(at(6, 0)), PrayerName.fajr);
    });

    test('between sunrise and Dhuhr -> Dhuhr, no current prayer', () {
      expect(times.nextPrayerAt(at(9, 0)).prayer, PrayerName.dhuhr);
      expect(times.currentPrayerAt(at(9, 0)), isNull);
    });

    test('exactly at Asr time -> next is Maghrib, current is Asr', () {
      expect(times.nextPrayerAt(times.asr).prayer, PrayerName.maghrib);
      expect(times.currentPrayerAt(times.asr), PrayerName.asr);
    });

    test("after Isha -> tomorrow's Fajr; table keeps today's times", () {
      final n = times.nextPrayerAt(at(22, 0));
      expect(n.prayer, PrayerName.fajr);
      expect(n.isTomorrow, isTrue);
      expect(n.time, DateTime(2026, 11, 15, 5, 0));
      expect(n.timeUntil(at(22, 0)), const Duration(hours: 7));
      expect(times.fajr, DateTime(2026, 11, 14, 5, 0));
      expect(times.currentPrayerAt(at(22, 0)), PrayerName.isha);
    });

    test('timeUntil is never negative', () {
      final n = times.nextPrayerAt(at(10, 0));
      expect(n.timeUntil(at(13, 0)), Duration.zero);
    });

    test('hasStarted', () {
      expect(times.hasStarted(PrayerName.dhuhr, at(12, 0)), isFalse);
      expect(times.hasStarted(PrayerName.dhuhr, at(12, 15)), isTrue);
    });
  });

  group('formatCountdown', () {
    test('formats HH:MM:SS', () {
      expect(
        formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
      expect(formatCountdown(const Duration(hours: 26)), '26:00:00');
    });

    test('negative durations clamp to zero', () {
      expect(formatCountdown(const Duration(seconds: -5)), '00:00:00');
      expect(formatCountdown(const Duration(hours: -3)), '00:00:00');
    });
  });

  group('AdhanService', () {
    test('returns today and tomorrow in order', () async {
      final t = await AdhanService().getTimes(
        24.8607,
        67.0011,
        now: DateTime(2026, 3, 10, 12),
      );
      expect(t.date, DateTime(2026, 3, 10));
      expect(t.tomorrow.date, DateTime(2026, 3, 11));
      expect(t.fajr.isBefore(t.sunrise), isTrue);
      expect(t.sunrise.isBefore(t.dhuhr), isTrue);
      expect(t.isha.isBefore(t.tomorrow.fajr), isTrue);
    });

    test(
      'Hanafi Asr is later than Shafi Asr; Karachi defaults to Hanafi',
      () async {
        final now = DateTime(2026, 6, 1, 12);
        final shafi = await AdhanService().getTimes(
          24.86,
          67.0,
          method: 'MWL',
          madhab: AsrMadhab.shafi,
          now: now,
        );
        final hanafi = await AdhanService().getTimes(
          24.86,
          67.0,
          method: 'MWL',
          madhab: AsrMadhab.hanafi,
          now: now,
        );
        expect(hanafi.asr.isAfter(shafi.asr), isTrue);
        expect(AsrMadhab.defaultFor('Karachi'), AsrMadhab.hanafi);
        expect(AsrMadhab.defaultFor('ISNA'), AsrMadhab.shafi);
        final mwlDefault = await AdhanService().getTimes(
          24.86,
          67.0,
          method: 'MWL',
          now: now,
        );
        expect(mwlDefault.asr, shafi.asr);
      },
    );
  });
}
