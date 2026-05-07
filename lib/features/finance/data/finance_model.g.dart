// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceModelAdapter extends TypeAdapter<FinanceModel> {
  @override
  final int typeId = 7;

  @override
  FinanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceModel(
      id: fields[0] as String?,
      type: fields[1] as int? ?? 0,
      contactName: fields[2] as String,
      amountPaisa: fields[3] as int,
      note: fields[4] as String? ?? '',
      date: fields[5] as DateTime?,
      dueDate: fields[6] as DateTime?,
      isSettled: fields[7] as bool? ?? false,
      settledDate: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.amountPaisa)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.isSettled)
      ..writeByte(8)
      ..write(obj.settledDate)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
