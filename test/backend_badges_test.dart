import 'package:barakah_time/data/repositories/spiritual_pulse_repository_impl.dart';
import 'package:barakah_time/domain/entities/badge.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/spiritual_pulse.dart';
import 'package:flutter_test/flutter_test.dart';

SpiritualActivity _a(DateTime t, {int points = 10, String id = ''}) =>
    SpiritualActivity(
      id: id.isEmpty ? t.toIso8601String() : id,
      type: 'dhikr',
      timestamp: t,
      points: points,
    );

void main() {
  const compute = SpiritualPulseRepositoryImpl.computeEarnedBadgeIds;
  const longest = SpiritualPulseRepositoryImpl.calculateLongestStreak;

  group('longest streak', () {
    test('empty -> 0', () => expect(longest(const []), 0));

    test('finds the longest run, not the current one', () {
      final days = [
        for (var d = 1; d <= 9; d++) DateTime(2026, 3, d, 12), // 9-day run
        DateTime(2026, 3, 20),
        DateTime(2026, 3, 21),
      ];
      expect(longest(days), 9);
    });

    test('multiple activities per day count once; crosses month ends', () {
      expect(
        longest([
          DateTime(2026, 1, 31, 8),
          DateTime(2026, 1, 31, 20),
          DateTime(2026, 2, 1, 5),
          DateTime(2026, 2, 2, 23),
        ]),
        3,
      );
    });
  });

  group('badge ids', () {
    test('no activities -> no badges', () {
      expect(compute(const []), isEmpty);
    });

    test('first activity earns first_step only', () {
      expect(compute([_a(DateTime(2026, 1, 1))]), {BadgeIds.firstStep});
    });

    test('streak badges use the longest streak (persist after a break)', () {
      final acts = [
        for (var d = 0; d < 30; d++) _a(DateTime(2026, 1, 1 + d)),
        _a(DateTime(2026, 6, 1)),
      ];
      final ids = compute(acts);
      expect(ids, containsAll([BadgeIds.streak7, BadgeIds.streak30]));
      expect(ids, isNot(contains(BadgeIds.streak100)));
    });

    test(
      'daily achiever on any day reaching 100 points, not only last week',
      () {
        final acts = [
          _a(DateTime(2025, 1, 1, 8), points: 60, id: 'a'),
          _a(DateTime(2025, 1, 1, 9), points: 40, id: 'b'),
        ];
        expect(compute(acts), contains(BadgeIds.dailyAchiever));
      },
    );

    test('veteran at 50 activities, points_1000 at 1000 lifetime points', () {
      final acts = [
        for (var i = 0; i < 50; i++)
          _a(DateTime(2025, 1, 1).add(Duration(days: i * 3)), points: 20),
      ];
      final ids = compute(acts);
      expect(ids, contains(BadgeIds.spiritualVeteran));
      expect(ids, contains(BadgeIds.points1000)); // 50 * 20
    });

    test('sortBadgeIds follows BadgeIds.all, unknown ids last', () {
      expect(
        SpiritualPulseRepositoryImpl.sortBadgeIds([
          'zzz',
          BadgeIds.points1000,
          BadgeIds.firstStep,
          BadgeIds.streak7,
        ]),
        [BadgeIds.firstStep, BadgeIds.streak7, BadgeIds.points1000, 'zzz'],
      );
    });

    test('l10n keys', () {
      expect(badgeL10nKey(BadgeIds.streak7), 'badge_streak_7');
      expect(badgeDescriptionL10nKey(BadgeIds.streak7), 'badge_streak_7_desc');
    });
  });

  group('motivation', () {
    test('levels by points', () {
      expect(MotivationLevelX.forPoints(0), MotivationLevel.start);
      expect(MotivationLevelX.forPoints(10), MotivationLevel.started);
      expect(MotivationLevelX.forPoints(50), MotivationLevel.halfway);
      expect(MotivationLevelX.forPoints(80), MotivationLevel.almost);
      expect(MotivationLevelX.forPoints(120), MotivationLevel.achieved);
      expect(MotivationLevel.halfway.l10nKey, 'motivation_halfway');
    });

    test('entity keeps an English fallback', () {
      const e = SpiritualPulseEntity(
        dailyPoints: [0, 0, 0, 0, 0, 0, 100],
        currentStreak: 1,
        motivation: MotivationLevel.achieved,
        recentActivities: [],
        badges: [],
      );
      expect(e.motivationalMessage, contains('MashaAllah'));
    });
  });
}
