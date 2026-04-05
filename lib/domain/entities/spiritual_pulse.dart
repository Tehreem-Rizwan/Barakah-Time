import 'package:equatable/equatable.dart';
import 'spiritual_activity.dart';

class SpiritualPulseEntity extends Equatable {
  final List<int> dailyPoints; // Points from 0-100 for the last 7 days
  final int currentStreak;
  final String motivationalMessage;
  final List<SpiritualActivity> recentActivities;
  final List<String> badges;

  const SpiritualPulseEntity({
    required this.dailyPoints,
    required this.currentStreak,
    required this.motivationalMessage,
    required this.recentActivities,
    required this.badges,
  });

  @override
  List<Object?> get props => [
    dailyPoints,
    currentStreak,
    motivationalMessage,
    recentActivities,
    badges,
  ];
}
