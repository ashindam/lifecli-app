// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassEntryModelAdapter extends TypeAdapter<ClassEntryModel> {
  @override
  final int typeId = 12;

  @override
  ClassEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassEntryModel(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      dayOfWeek: (fields[2] as List?)?.cast<int>() ?? [],
      startTime: fields[3] as String? ?? '',
      endTime: fields[4] as String? ?? '',
      room: fields[5] as String? ?? '',
      teacherName: fields[6] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, ClassEntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.dayOfWeek)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.room)
      ..writeByte(6)
      ..write(obj.teacherName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamModelAdapter extends TypeAdapter<ExamModel> {
  @override
  final int typeId = 13;

  @override
  ExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamModel(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      date: fields[2] as DateTime,
      time: fields[3] as String? ?? '',
      venue: fields[4] as String? ?? '',
      examType: fields[5] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ExamModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.venue)
      ..writeByte(5)
      ..write(obj.examType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssignmentModelAdapter extends TypeAdapter<AssignmentModel> {
  @override
  final int typeId = 14;

  @override
  AssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentModel(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      title: fields[2] as String,
      weightage: fields[3] as double? ?? 0.0,
      dueDate: fields[4] as DateTime,
      submissionType: fields[5] as int? ?? 0,
      status: fields[6] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.weightage)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.submissionType)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 15;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      date: fields[2] as DateTime,
      isPresent: fields[3] as bool? ?? true,
      minimumPercent: fields[4] as double? ?? 75.0,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isPresent)
      ..writeByte(4)
      ..write(obj.minimumPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
