// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeComponentAdapter extends TypeAdapter<GradeComponent> {
  @override
  final int typeId = 18;

  @override
  GradeComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradeComponent(
      name: fields[0] as String,
      weightagePercent: fields[1] as double,
      marksObtained: fields[2] as double?,
      totalMarks: fields[3] as double? ?? 100.0,
    );
  }

  @override
  void write(BinaryWriter writer, GradeComponent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.weightagePercent)
      ..writeByte(2)
      ..write(obj.marksObtained)
      ..writeByte(3)
      ..write(obj.totalMarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GradeCourseModelAdapter extends TypeAdapter<GradeCourseModel> {
  @override
  final int typeId = 19;

  @override
  GradeCourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradeCourseModel(
      id: fields[0] as String?,
      courseName: fields[1] as String,
      creditHours: fields[2] as int? ?? 3,
      components: (fields[3] as List?)?.cast<GradeComponent>() ?? [],
      semesterId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GradeCourseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.creditHours)
      ..writeByte(3)
      ..write(obj.components)
      ..writeByte(4)
      ..write(obj.semesterId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeCourseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SemesterModelAdapter extends TypeAdapter<SemesterModel> {
  @override
  final int typeId = 20;

  @override
  SemesterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SemesterModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      courses: (fields[2] as List?)?.cast<GradeCourseModel>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, SemesterModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.courses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
