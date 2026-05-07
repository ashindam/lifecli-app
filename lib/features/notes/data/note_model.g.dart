// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 1;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      body: fields[2] as String? ?? '',
      tags: (fields[3] as List?)?.cast<String>() ?? [],
      colorLabel: fields[4] as int? ?? 0,
      courseLink: fields[5] as String?,
      isPinned: fields[6] as bool? ?? false,
      imagePath: fields[7] as String?,
      linkedTaskId: fields[8] as String?,
      isExported: fields[9] as bool? ?? false,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.colorLabel)
      ..writeByte(5)
      ..write(obj.courseLink)
      ..writeByte(6)
      ..write(obj.isPinned)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.linkedTaskId)
      ..writeByte(9)
      ..write(obj.isExported)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
