// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spiritual_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpiritualActivityAdapter extends TypeAdapter<SpiritualActivity> {
  @override
  final int typeId = 0;

  @override
  SpiritualActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpiritualActivity(
      id: fields[0] as String,
      type: fields[1] as String,
      subType: fields[2] as String?,
      timestamp: fields[3] as DateTime,
      points: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpiritualActivity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.subType)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpiritualActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
