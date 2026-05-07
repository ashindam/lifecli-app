// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'inbox_item_model.dart';

class InboxItemModelAdapter extends TypeAdapter<InboxItemModel> {
  @override final int typeId = 28;
  @override
  InboxItemModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return InboxItemModel(id: f[0], content: f[1] ?? '', createdAt: f[2], status: f[3] ?? 0, convertedTo: f[4]);
  }
  @override
  void write(BinaryWriter writer, InboxItemModel obj) {
    writer..writeByte(5)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.content)
      ..writeByte(2)..write(obj.createdAt)..writeByte(3)..write(obj.status)..writeByte(4)..write(obj.convertedTo);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is InboxItemModelAdapter && typeId == o.typeId;
}
