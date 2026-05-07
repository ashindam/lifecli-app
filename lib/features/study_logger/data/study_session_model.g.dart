// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySessionModelAdapter extends TypeAdapter<StudySessionModel> {
  @override
  final int typeId = 21;

  @override
  StudySessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySessionModel(
      id: fields[0] as String?,
      subject: fields[1] as String? ?? '',
      durationMinutes: fields[2] as int? ?? 0,
      date: fields[3] as DateTime?,
      notes: fields[4] as String? ?? '',
      topicsCovered: (fields[5] as List?)?.cast<String>() ?? [],
      fromPomodoro: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.topicsCovered)
      ..writeByte(6)
      ..write(obj.fromPomodoro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
