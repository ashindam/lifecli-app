// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'load_shedding_model.dart';

class LoadSheddingSlotAdapter extends TypeAdapter<LoadSheddingSlot> {
  @override final int typeId = 27;
  @override
  LoadSheddingSlot read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return LoadSheddingSlot(id: f[0], dayOfWeek: f[1] ?? 1, startTime: f[2] ?? '00:00',
        endTime: f[3] ?? '01:00', area: f[4] ?? 'My Area', isEnabled: f[5] ?? true);
  }
  @override
  void write(BinaryWriter writer, LoadSheddingSlot obj) {
    writer..writeByte(6)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.dayOfWeek)
      ..writeByte(2)..write(obj.startTime)..writeByte(3)..write(obj.endTime)
      ..writeByte(4)..write(obj.area)..writeByte(5)..write(obj.isEnabled);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is LoadSheddingSlotAdapter && typeId == o.typeId;
}
