import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'saved_verse.g.dart';

@HiveType(typeId: 2)
class SavedVerse extends Equatable {
  @HiveField(0)
  final String id; // format: 'surahNumber:ayahNumber'
  @HiveField(1)
  final int surahNumber;
  @HiveField(2)
  final int ayahNumber;
  @HiveField(3)
  final String text;
  @HiveField(4)
  final String? translation;
  @HiveField(5)
  final String surahName;
  @HiveField(6)
  final DateTime timestamp;

  const SavedVerse({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.translation,
    required this.surahName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    surahNumber,
    ayahNumber,
    text,
    translation,
    surahName,
    timestamp,
  ];
}
