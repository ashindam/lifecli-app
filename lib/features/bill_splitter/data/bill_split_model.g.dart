// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_split_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillSplitModelAdapter extends TypeAdapter<BillSplitModel> {
  @override
  final int typeId = 8;

  @override
  BillSplitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillSplitModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      totalAmountPaisa: fields[2] as int,
      participantsRaw: (fields[3] as List?)?.cast<Map>() ?? [],
      isEqualSplit: fields[4] as bool? ?? true,
      date: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BillSplitModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.totalAmountPaisa)
      ..writeByte(3)
      ..write(obj.participantsRaw)
      ..writeByte(4)
      ..write(obj.isEqualSplit)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillSplitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
