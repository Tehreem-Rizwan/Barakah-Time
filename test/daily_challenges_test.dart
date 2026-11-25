import 'package:barakah_time/core/utils/daily_challenges.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SpiritualActivity _a(String type, [String? sub]) => SpiritualActivity(
  id: '$type-$sub',
  type: type,
  subType: sub,
  timestamp: DateTime(2026, 11, 24, 10),
  points: 10,
);

void main() {
  test('nothing logged: nothing done', () {
    final s = DailyChallenges.evaluate(const []);
    expect(s.map((c) => c.kind), ChallengeKind.values);
    expect(s.any((c) => c.done), isFalse);
    expect(s.first.goal, 5);
  });

  test('counts distinct prayers and completes from existing activities', () {
    final some = DailyChallenges.evaluate([
      _a('prayer', 'fajr'),
      _a('prayer', 'fajr'),
      _a('prayer', 'dhuhr'),
      _a('quran', 'Al-Mulk'),
    ]);
    expect(some[0].progress, 2);
    expect(some[0].done, isFalse);
    expect(some[1].done, isTrue);
    expect(some[2].done, isFalse);
    expect(DailyChallenges.allDone(some), isFalse);

    final all = DailyChallenges.evaluate([
      for (final p in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'])
        _a('prayer', p),
      _a('quran'),
      _a('dhikr', 'tasbeeh'),
    ]);
    expect(DailyChallenges.allDone(all), isTrue);
  });

  test('unknown prayer names do not count', () {
    final s = DailyChallenges.evaluate([_a('prayer', 'sunrise')]);
    expect(s.first.progress, 0);
  });

  group('perfect days', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('weekly count over the last 7 days', () async {
      final p = PerfectDays(await SharedPreferences.getInstance());
      final today = DateTime(2026, 11, 24);
      await p.mark(today);
      await p.mark(today); // idempotent
      await p.mark(DateTime(2026, 11, 20));
      await p.mark(DateTime(2026, 11, 17)); // 7 days ago: outside
      expect(p.contains(today), isTrue);
      expect(p.inLastWeek(today), 2);
    });

    test('corrupted storage is treated as empty', () async {
      SharedPreferences.setMockInitialValues({PerfectDays.key: 'x'});
      final p = PerfectDays(await SharedPreferences.getInstance());
      expect(p.inLastWeek(DateTime(2026, 11, 24)), 0);
    });
  });
}
