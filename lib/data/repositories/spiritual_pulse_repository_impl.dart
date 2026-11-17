import 'package:hive/hive.dart';
import '../../core/services/user_data_sync_service.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../domain/entities/spiritual_pulse.dart';
import '../../domain/repositories/spiritual_pulse_repository.dart';
import '../datasources/local/local_store.dart';

/// Hive is the offline cache / source for the UI; every new activity and
/// newly earned badge is also pushed to Firestore when signed in.
class SpiritualPulseRepositoryImpl implements SpiritualPulseRepository {
  static const String _boxName = LocalBoxes.activities;

  final UserDataSync? sync;

  SpiritualPulseRepositoryImpl({this.sync});

  /// Serializes writes so concurrent check-then-write can't create duplicates.
  Future<void> _writeChain = Future.value();

  @override
  Future<SpiritualPulseEntity> getPulseData() async {
    final box = await Hive.openBox<SpiritualActivity>(_boxName);
    // Hive orders values by key (and keys are ids), so sort chronologically.
    final activities =
        box.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final now = DateTime.now();

    final dailyPoints = dailyPointsForLastWeek(activities, now);
    final recentActivities = activities.reversed.take(10).toList();
    final timestamps = activities.map((a) => a.timestamp);
    final streak = calculateStreak(timestamps, now);
    final longest = calculateLongestStreak(timestamps);
    final total = activities.fold<int>(0, (s, a) => s + a.points);

    final badges = await _updateBadges(
      computeEarnedBadgeIds(activities, longestStreak: longest),
      now,
    );

    return SpiritualPulseEntity(
      dailyPoints: dailyPoints,
      currentStreak: streak,
      longestStreak: longest,
      totalPoints: total,
      motivation: MotivationLevelX.forPoints(dailyPoints.last),
      recentActivities: recentActivities,
      allActivities: activities.reversed.toList(),
      badges: badges,
    );
  }

  /// Persists newly earned badges (locally + cloud) and returns all earned
  /// badge ids in display order.
  Future<List<String>> _updateBadges(
    Set<String> qualifying,
    DateTime now,
  ) async {
    final meta = await Hive.openBox(LocalBoxes.pulseMeta);
    final earned = UserDataSyncService.readLocalBadges(meta);
    final newOnes = {
      for (final id in qualifying)
        if (!earned.containsKey(id)) id: now,
    };
    if (newOnes.isNotEmpty) {
      earned.addAll(newOnes);
      await UserDataSyncService.writeLocalBadges(meta, earned);
      sync?.pushBadges(newOnes);
    }
    return sortBadgeIds(earned.keys);
  }

  @override
  Future<List<SpiritualActivity>> getActivitiesOn(DateTime day) async {
    final box = await Hive.openBox<SpiritualActivity>(_boxName);
    return box.values.where((a) => isSameDay(a.timestamp, day)).toList();
  }

  @override
  Future<bool> logActivity(SpiritualActivity activity) {
    final result = _writeChain.then((_) => _logActivity(activity));
    _writeChain = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<bool> _logActivity(SpiritualActivity activity) async {
    final box = await Hive.openBox<SpiritualActivity>(_boxName);

    // Idempotent by id (e.g. deterministic "surah_<n>_<yyyyMMdd>" ids).
    if (box.containsKey(activity.id) ||
        box.values.any((a) => a.id == activity.id)) {
      return false;
    }

    // For prayers, we only want one entry per prayer per day
    if (activity.type == 'prayer' &&
        box.values.any(
          (a) =>
              a.type == 'prayer' &&
              a.subType == activity.subType &&
              isSameDay(a.timestamp, activity.timestamp),
        )) {
      return false;
    }

    await box.put(activity.id, activity);
    final s = sync;
    if (s != null && s.currentUid != null) {
      s.pushActivity(
        activity,
        longestStreak: calculateLongestStreak(
          box.values.map((a) => a.timestamp),
        ),
      );
    }
    return true;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Points (capped at 100) for each of the last 7 calendar days, oldest
  /// first, ending with [now]'s day. Uses calendar-day arithmetic so DST
  /// transitions don't skip or repeat a day.
  static List<int> dailyPointsForLastWeek(
    List<SpiritualActivity> activities,
    DateTime now,
  ) {
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      var points = 0;
      for (final a in activities) {
        if (isSameDay(a.timestamp, date)) points += a.points;
      }
      return points > 100 ? 100 : points;
    });
  }

  /// Consecutive days with activity, ending today or yesterday.
  static int calculateStreak(Iterable<DateTime> timestamps, DateTime now) {
    final days =
        timestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet();
    if (days.isEmpty) return 0;

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime cursor;
    if (days.contains(today)) {
      cursor = today;
    } else if (days.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  /// Longest run of consecutive calendar days with any activity.
  static int calculateLongestStreak(Iterable<DateTime> timestamps) {
    final days =
        timestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet().toList()
          ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in days) {
      final expected =
          prev == null ? null : DateTime(prev.year, prev.month, prev.day + 1);
      run = (expected != null && expected == d) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// Badge ids [activities] currently qualify for. Streak badges use the
  /// longest streak ever, so they are never lost.
  static Set<String> computeEarnedBadgeIds(
    List<SpiritualActivity> activities, {
    int? longestStreak,
  }) {
    final ids = <String>{};
    if (activities.isEmpty) return ids;
    ids.add(BadgeIds.firstStep);
    final longest =
        longestStreak ??
        calculateLongestStreak(activities.map((a) => a.timestamp));
    if (longest >= 7) ids.add(BadgeIds.streak7);
    if (longest >= 30) ids.add(BadgeIds.streak30);
    if (longest >= 100) ids.add(BadgeIds.streak100);

    final perDay = <DateTime, int>{};
    var total = 0;
    for (final a in activities) {
      final d = DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day);
      perDay[d] = (perDay[d] ?? 0) + a.points;
      total += a.points;
    }
    if (perDay.values.any((p) => p >= 100)) ids.add(BadgeIds.dailyAchiever);
    if (activities.length >= 50) ids.add(BadgeIds.spiritualVeteran);
    if (total >= 1000) ids.add(BadgeIds.points1000);
    return ids;
  }

  /// Sorts known ids in [BadgeIds.all] order; unknown ids go last.
  static List<String> sortBadgeIds(Iterable<String> ids) {
    int rank(String id) {
      final i = BadgeIds.all.indexOf(id);
      return i < 0 ? BadgeIds.all.length : i;
    }

    return ids.toList()..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.compareTo(b);
    });
  }
}
