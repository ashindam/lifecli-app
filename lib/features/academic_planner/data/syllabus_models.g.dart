// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syllabus_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyllabusTopicModelAdapter extends TypeAdapter<SyllabusTopicModel> {
  @override
  final int typeId = 16;

  @override
  SyllabusTopicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusTopicModel(
      id: fields[0] as String?,
      courseId: fields[1] as String,
      topicName: fields[2] as String,
      status: fields[3] as int? ?? 0,
      isStarred: fields[4] as bool? ?? false,
      linkedStudySessionIds: (fields[5] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusTopicModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.topicName)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.isStarred)
      ..writeByte(5)
      ..write(obj.linkedStudySessionIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusTopicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyllabusCourseModelAdapter extends TypeAdapter<SyllabusCourseModel> {
  @override
  final int typeId = 17;

  @override
  SyllabusCourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusCourseModel(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      topics: (fields[2] as List?)?.cast<SyllabusTopicModel>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusCourseModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.topics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusCourseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
