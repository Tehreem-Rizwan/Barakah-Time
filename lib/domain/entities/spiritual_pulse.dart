import 'package:equatable/equatable.dart';

class SpiritualPulseEntity extends Equatable {
  final List<int> dailyPoints; // Points from 0-100 for the last 7 days
  final int currentStreak;
  final String motivationalMessage;

  const SpiritualPulseEntity({
    required this.dailyPoints,
    required this.currentStreak,
    required this.motivationalMessage,
  });

  @override
  List<Object?> get props => [dailyPoints, currentStreak, motivationalMessage];
}
