import 'package:equatable/equatable.dart';
import 'badge.dart';
import 'spiritual_activity.dart';

class SpiritualPulseEntity extends Equatable {
  final List<int> dailyPoints; // Points from 0-100 for the last 7 days
  final int currentStreak;

  /// Longest run of consecutive active days ever.
  final int longestStreak;

  /// Lifetime points (all activities, not capped per day).
  final int totalPoints;

  /// Today's goal progress; localize with `motivation.l10nKey`.
  final MotivationLevel motivation;
  final List<SpiritualActivity> recentActivities;

  /// Every logged activity, newest first (Activity History page). Defaults
  /// to [recentActivities] when not provided.
  final List<SpiritualActivity> allActivities;

  /// Earned badge ids ([BadgeIds]), in display order. Once earned a badge
  /// is kept (it does not disappear when a streak breaks). Localize with
  /// [badgeL10nKey].
  final List<String> badges;

  const SpiritualPulseEntity({
    required this.dailyPoints,
    required this.currentStreak,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.motivation = MotivationLevel.start,
    required this.recentActivities,
    required this.badges,
    List<SpiritualActivity>? allActivities,
  }) : allActivities = allActivities ?? recentActivities;

  /// English fallback text for [motivation]. Prefer localizing
  /// `motivation.l10nKey`.
  String get motivationalMessage {
    switch (motivation) {
      case MotivationLevel.achieved:
        return "MashaAllah! You've achieved your spiritual goals for today. ✨";
      case MotivationLevel.almost:
        return 'Great progress! Just a little more to hit your target. 🚀';
      case MotivationLevel.halfway:
        return "You're halfway through! Keep up the momentum. 💪";
      case MotivationLevel.started:
        return 'Good start! Keep moving towards your goals. ⚡';
      case MotivationLevel.start:
        return 'Start your spiritual journey for today. Every step counts! 🌱';
    }
  }

  @override
  List<Object?> get props => [
    dailyPoints,
    currentStreak,
    longestStreak,
    totalPoints,
    motivation,
    recentActivities,
    allActivities,
    badges,
  ];
}
