import 'package:barakah_time/core/services/notification_service.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = AdhanService();
  List<DailyPrayerTimes> week(DateTime from) => service.timesForDays(
    24.86,
    67.0,
    from,
    NotificationService.daysAhead,
    method: 'Karachi',
  );

  test('timesForDays returns consecutive calendar days', () {
    final days = week(DateTime(2026, 3, 28, 12)); // spans DST changes in EU
    expect(days.length, 7);
    for (var i = 0; i < 7; i++) {
      expect(days[i].date, DateTime(2026, 3, 28 + i));
      expect(days[i].fajr.isBefore(days[i].dhuhr), isTrue);
      expect(days[i].maghrib.isBefore(days[i].isha), isTrue);
    }
  });

  test('timesForDate matches getTimes for today/tomorrow', () async {
    final now = DateTime(2026, 11, 15, 10);
    final t = await service.getTimes(24.86, 67.0, method: 'MWL', now: now);
    final d = service.timesForDate(24.86, 67.0, now, method: 'MWL');
    expect(t.today, d);
  });

  test('7 days ahead = 35 reminders when scheduled before Fajr', () {
    final days = week(DateTime(2026, 11, 15));
    final schedule = NotificationService.computeSchedule(
      days,
      DateTime(2026, 11, 15, 0, 1),
    );
    expect(schedule.length, 35);
    expect(schedule.map((s) => s.id).toSet().length, 35);
    expect(schedule.first.prayer, PrayerName.fajr);
    expect(schedule.last.dayIndex, 6);
    expect(schedule.last.prayer, PrayerName.isha);
  });

  test('skips times that already passed today', () {
    final days = week(DateTime(2026, 11, 15));
    final afterAsr = days[0].asr.add(const Duration(minutes: 1));
    final schedule = NotificationService.computeSchedule(days, afterAsr);
    expect(schedule.length, 32); // maghrib + isha today, then 6 full days
    expect(schedule.first.prayer, PrayerName.maghrib);
    expect(schedule.every((s) => s.time.isAfter(afterAsr)), isTrue);
    // ids are stable: dayIndex * 10 + prayer index
    expect(schedule.first.id, PrayerName.maghrib.index);
    expect(schedule[2].id, 10 + PrayerName.fajr.index);
  });

  test('exactly at a prayer time it is not re-scheduled', () {
    final days = week(DateTime(2026, 11, 15));
    final schedule = NotificationService.computeSchedule(days, days[0].fajr);
    expect(schedule.first.prayer, PrayerName.dhuhr);
  });

  test('payload marks prayer notifications', () {
    final p = PrayerNotificationPayload.of(PrayerName.asr);
    expect(p, 'prayer:asr');
    expect(PrayerNotificationPayload.isPrayer(p), isTrue);
    expect(PrayerNotificationPayload.isPrayer(null), isFalse);
  });
}
