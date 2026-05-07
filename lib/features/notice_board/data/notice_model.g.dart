// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'notice_model.dart';

class NoticeModelAdapter extends TypeAdapter<NoticeModel> {
  @override final int typeId = 26;
  @override
  NoticeModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return NoticeModel(id: f[0], title: f[1] ?? '', body: f[2] ?? '', sourceTag: f[3] ?? 2,
        date: f[4], isPinned: f[5] ?? false, isArchived: f[6] ?? false, createdAt: f[7]);
  }
  @override
  void write(BinaryWriter writer, NoticeModel obj) {
    writer..writeByte(8)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.title)..writeByte(2)..write(obj.body)
      ..writeByte(3)..write(obj.sourceTag)..writeByte(4)..write(obj.date)
      ..writeByte(5)..write(obj.isPinned)..writeByte(6)..write(obj.isArchived)
      ..writeByte(7)..write(obj.createdAt);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is NoticeModelAdapter && typeId == o.typeId;
}
