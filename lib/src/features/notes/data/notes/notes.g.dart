// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotesAdapter extends TypeAdapter<Notes> {
  @override
  final int typeId = 1;

  @override
  Notes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notes(
      isBookmarked: fields[3] as bool,
      title: fields[0] as String,
      date: fields[1] as String,
      content: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Notes obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isBookmarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
