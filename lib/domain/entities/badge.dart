/// Stable badge ids. They are persisted (Hive + Firestore `badges/{id}`), so
/// never rename them. The UI localizes them via [badgeL10nKey].
class BadgeIds {
  BadgeIds._();

  static const firstStep = 'first_step';
  static const streak7 = 'streak_7';
  static const streak30 = 'streak_30';
  static const streak100 = 'streak_100';
  static const dailyAchiever = 'daily_achiever';
  static const spiritualVeteran = 'spiritual_veteran';
  static const points1000 = 'points_1000';

  /// Canonical display order.
  static const List<String> all = [
    firstStep,
    streak7,
    streak30,
    streak100,
    dailyAchiever,
    spiritualVeteran,
    points1000,
  ];
}

/// l10n key for a badge's name, e.g. `badge_streak_7`. Description keys are
/// `badge_<id>_desc`.
String badgeL10nKey(String badgeId) => 'badge_$badgeId';

String badgeDescriptionL10nKey(String badgeId) => 'badge_${badgeId}_desc';

/// Daily-goal progress level; the UI shows `motivation_<name>` from l10n.
enum MotivationLevel { start, started, halfway, almost, achieved }

extension MotivationLevelX on MotivationLevel {
  String get l10nKey => 'motivation_$name';

  static MotivationLevel forPoints(int todayPoints) {
    if (todayPoints >= 100) return MotivationLevel.achieved;
    if (todayPoints >= 75) return MotivationLevel.almost;
    if (todayPoints >= 50) return MotivationLevel.halfway;
    if (todayPoints > 0) return MotivationLevel.started;
    return MotivationLevel.start;
  }
}
