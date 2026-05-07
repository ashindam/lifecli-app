// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuition_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TuitionStudentModelAdapter extends TypeAdapter<TuitionStudentModel> {
  @override
  final int typeId = 9;

  @override
  TuitionStudentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TuitionStudentModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      subject: fields[2] as String? ?? '',
      monthlySalaryPaisa: fields[3] as int? ?? 0,
      sessionsPerMonth: fields[4] as int? ?? 0,
      contactNumber: fields[5] as String? ?? '',
      completedSessions: fields[6] as int? ?? 0,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TuitionStudentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.monthlySalaryPaisa)
      ..writeByte(4)
      ..write(obj.sessionsPerMonth)
      ..writeByte(5)
      ..write(obj.contactNumber)
      ..writeByte(6)
      ..write(obj.completedSessions)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TuitionStudentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TuitionSessionModelAdapter extends TypeAdapter<TuitionSessionModel> {
  @override
  final int typeId = 10;

  @override
  TuitionSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TuitionSessionModel(
      id: fields[0] as String?,
      studentId: fields[1] as String,
      date: fields[2] as DateTime,
      isPresent: fields[3] as bool? ?? true,
      note: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, TuitionSessionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isPresent)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TuitionSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TuitionPaymentModelAdapter extends TypeAdapter<TuitionPaymentModel> {
  @override
  final int typeId = 11;

  @override
  TuitionPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TuitionPaymentModel(
      id: fields[0] as String?,
      studentId: fields[1] as String,
      amountPaisa: fields[2] as int,
      note: fields[3] as String? ?? '',
      date: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TuitionPaymentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.amountPaisa)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TuitionPaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
