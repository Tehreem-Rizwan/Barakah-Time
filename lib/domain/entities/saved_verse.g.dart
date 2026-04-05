// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_verse.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedVerseAdapter extends TypeAdapter<SavedVerse> {
  @override
  final int typeId = 2;

  @override
  SavedVerse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedVerse(
      id: fields[0] as String,
      surahNumber: fields[1] as int,
      ayahNumber: fields[2] as int,
      text: fields[3] as String,
      translation: fields[4] as String?,
      surahName: fields[5] as String,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedVerse obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.ayahNumber)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.translation)
      ..writeByte(5)
      ..write(obj.surahName)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedVerseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
