import 'package:barakah_time/data/repositories/spiritual_pulse_repository_impl.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:flutter_test/flutter_test.dart';

SpiritualActivity _a(DateTime t, {int points = 10}) => SpiritualActivity(
  id: t.toIso8601String(),
  type: 'dhikr',
  timestamp: t,
  points: points,
);

void main() {
  const streak = SpiritualPulseRepositoryImpl.calculateStreak;

  test('empty -> 0', () {
    expect(streak(const [], DateTime(2026, 11, 14)), 0);
  });

  test('consecutive days ending today', () {
    final now = DateTime(2026, 11, 14, 20);
    expect(
      streak([
        DateTime(2026, 11, 14, 8),
        DateTime(2026, 11, 14, 9),
        DateTime(2026, 11, 13, 23, 59),
        DateTime(2026, 11, 12, 0, 1),
        DateTime(2026, 11, 10, 12),
      ], now),
      3,
    );
  });

  test('streak still counts when last activity was yesterday', () {
    expect(
      streak([
        DateTime(2026, 11, 13),
        DateTime(2026, 11, 12),
      ], DateTime(2026, 11, 14, 10)),
      2,
    );
  });

  test('gap of two days resets streak', () {
    expect(streak([DateTime(2026, 11, 12)], DateTime(2026, 11, 14)), 0);
  });

  test('across month/year boundaries', () {
    expect(
      streak([
        DateTime(2027, 1, 1, 7),
        DateTime(2026, 12, 31, 7),
        DateTime(2026, 12, 30, 7),
      ], DateTime(2027, 1, 1, 9)),
      3,
    );
  });

  test('across DST transitions (calendar-day arithmetic)', () {
    // US spring-forward (Mar 8 2026) and EU fall-back (Oct 25 2026).
    final spring = [for (var d = 5; d <= 11; d++) DateTime(2026, 3, d, 0, 30)];
    expect(streak(spring, DateTime(2026, 3, 11, 23)), 7);
    final fall = [for (var d = 22; d <= 28; d++) DateTime(2026, 10, d, 23, 30)];
    expect(streak(fall, DateTime(2026, 10, 28, 1)), 7);
  });

  test('dailyPointsForLastWeek: 7 calendar days ending today, capped', () {
    final now = DateTime(2026, 3, 9, 12); // day after US DST change
    final pts = SpiritualPulseRepositoryImpl.dailyPointsForLastWeek([
      _a(DateTime(2026, 3, 9, 0, 10), points: 30),
      _a(DateTime(2026, 3, 8, 23, 50), points: 20),
      _a(DateTime(2026, 3, 8, 1), points: 200),
      _a(DateTime(2026, 3, 3, 9), points: 5),
      _a(DateTime(2026, 3, 2, 9), points: 99), // 8 days ago: excluded
    ], now);
    expect(pts, [5, 0, 0, 0, 0, 100, 30]);
  });
}
