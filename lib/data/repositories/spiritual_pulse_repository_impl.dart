import 'package:hive/hive.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../domain/entities/spiritual_pulse.dart';
import '../../domain/repositories/spiritual_pulse_repository.dart';

class SpiritualPulseRepositoryImpl implements SpiritualPulseRepository {
  static const String _boxName = 'spiritual_activities';

  @override
  Future<SpiritualPulseEntity> getPulseData() async {
    final box = await Hive.openBox<SpiritualActivity>(_boxName);
    final activities = box.values.toList();

    // Calculate daily points for the last 7 days
    final now = DateTime.now();
    final dailyPoints = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayActivities = activities.where((a) =>
          a.timestamp.year == date.year &&
          a.timestamp.month == date.month &&
          a.timestamp.day == date.day);

      int points = 0;
      for (var activity in dayActivities) {
        points += activity.points;
      }
      return points > 100 ? 100 : points;
    });

    final recentActivities = activities.reversed.take(10).toList();
    final streak = _calculateStreak(activities);

    // Badges logic
    List<String> badges = [];
    if (streak >= 7) badges.add('7 Day Streak');
    if (streak >= 30) badges.add('Monthly Master');
    if (dailyPoints.any((p) => p >= 100)) badges.add('Daily Achiever');
    if (activities.length >= 50) badges.add('Spiritual Veteran');

    return SpiritualPulseEntity(
      dailyPoints: dailyPoints,
      currentStreak: streak,
      motivationalMessage: _getMotivationalMessage(dailyPoints.last),
      recentActivities: recentActivities,
      badges: badges,
    );
  }

  @override
  Future<void> logActivity(SpiritualActivity activity) async {
    final box = await Hive.openBox<SpiritualActivity>(_boxName);
    
    // For prayers, we only want one entry per prayer per day
    if (activity.type == 'prayer') {
      final existing = box.values.where((a) => 
        a.type == 'prayer' && 
        a.subType == activity.subType && 
        a.timestamp.year == activity.timestamp.year &&
        a.timestamp.month == activity.timestamp.month &&
        a.timestamp.day == activity.timestamp.day
      );
      if (existing.isNotEmpty) return; // Already logged
    }

    await box.add(activity);
  }

  int _calculateStreak(List<SpiritualActivity> activities) {
    if (activities.isEmpty) return 0;
    
    final dates = activities
        .map((a) => DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    if (dates.isEmpty) return 0;

    // Check if the latest activity was today or yesterday
    if (dates.first.isBefore(today.subtract(const Duration(days: 1)))) {
      return 0;
    }

    DateTime current = dates.first;
    streak = 1;

    for (int i = 1; i < dates.length; i++) {
        if (dates[i] == current.subtract(const Duration(days: 1))) {
            streak++;
            current = dates[i];
        } else if (dates[i] == current) {
            continue;
        } else {
            break;
        }
    }

    return streak;
  }

  String _getMotivationalMessage(int todayPoints) {
    if (todayPoints >= 100) return "MashaAllah! You've achieved your spiritual goals for today. ✨";
    if (todayPoints >= 75) return "Great progress! Just a little more to hit your target. 🚀";
    if (todayPoints >= 50) return "You're halfway through! Keep up the momentum. 💪";
    if (todayPoints > 0) return "Good start! Keep moving towards your goals. ⚡";
    return "Start your spiritual journey for today. Every step counts! 🌱";
  }
}
