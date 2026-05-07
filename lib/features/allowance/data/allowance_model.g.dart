// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allowance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllowanceModelAdapter extends TypeAdapter<AllowanceModel> {
  @override
  final int typeId = 6;

  @override
  AllowanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllowanceModel(
      id: fields[0] as String?,
      monthlyAmountPaisa: fields[1] as int,
      receivedDate: fields[2] as int? ?? 1,
      savingsAmountPaisa: fields[3] as int? ?? 0,
      month: fields[4] as String,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AllowanceModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.monthlyAmountPaisa)
      ..writeByte(2)
      ..write(obj.receivedDate)
      ..writeByte(3)
      ..write(obj.savingsAmountPaisa)
      ..writeByte(4)
      ..write(obj.month)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllowanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
