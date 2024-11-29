// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarksAdapter extends TypeAdapter<Bookmarks> {
  @override
  final int typeId = 3;

  @override
  Bookmarks read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmarks(
      isBookMarked: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Bookmarks obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.isBookMarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
