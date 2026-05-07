// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'health_log_model.dart';

class HealthLogModelAdapter extends TypeAdapter<HealthLogModel> {
  @override final int typeId = 30;
  @override
  HealthLogModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return HealthLogModel(id: f[0], date: f[1], sleepHours: (f[2] as num?)?.toDouble() ?? 7,
        waterGlasses: f[3] ?? 0, mood: f[4] ?? 2, note: f[5] ?? '', createdAt: f[6]);
  }
  @override
  void write(BinaryWriter writer, HealthLogModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.date)
      ..writeByte(2)..write(obj.sleepHours)..writeByte(3)..write(obj.waterGlasses)
      ..writeByte(4)..write(obj.mood)..writeByte(5)..write(obj.note)
      ..writeByte(6)..write(obj.createdAt);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is HealthLogModelAdapter && typeId == o.typeId;
}
