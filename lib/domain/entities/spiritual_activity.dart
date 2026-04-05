import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'spiritual_activity.g.dart';

@HiveType(typeId: 0)
class SpiritualActivity extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String type; // 'prayer', 'quran', 'dhikr'
  @HiveField(2)
  final String? subType; // 'fajr', 'dhuhr', etc.
  @HiveField(3)
  final DateTime timestamp;
  @HiveField(4)
  final int points;

  const SpiritualActivity({
    required this.id,
    required this.type,
    this.subType,
    required this.timestamp,
    required this.points,
  });

  @override
  List<Object?> get props => [id, type, subType, timestamp, points];
}
