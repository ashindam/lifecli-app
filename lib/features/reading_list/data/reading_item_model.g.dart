// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'reading_item_model.dart';

class ReadingItemModelAdapter extends TypeAdapter<ReadingItemModel> {
  @override final int typeId = 31;
  @override
  ReadingItemModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return ReadingItemModel(id: f[0], title: f[1] ?? '', url: f[2], courseLink: f[3],
        type: f[4] ?? 3, status: f[5] ?? 0, createdAt: f[6]);
  }
  @override
  void write(BinaryWriter writer, ReadingItemModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.title)..writeByte(2)..write(obj.url)
      ..writeByte(3)..write(obj.courseLink)..writeByte(4)..write(obj.type)
      ..writeByte(5)..write(obj.status)..writeByte(6)..write(obj.createdAt);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is ReadingItemModelAdapter && typeId == o.typeId;
}
