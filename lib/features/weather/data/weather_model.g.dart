// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'weather_model.dart';

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override final int typeId = 23;
  @override
  WeatherModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return WeatherModel(city: f[0] ?? '', condition: f[1] ?? '', tempC: (f[2] as num?)?.toDouble() ?? 0,
        humidity: f[3] ?? 0, windKph: (f[4] as num?)?.toDouble() ?? 0, fetchedAt: f[5], conditionIcon: f[6] ?? '🌤');
  }
  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.city)..writeByte(1)..write(obj.condition)
      ..writeByte(2)..write(obj.tempC)..writeByte(3)..write(obj.humidity)
      ..writeByte(4)..write(obj.windKph)..writeByte(5)..write(obj.fetchedAt)
      ..writeByte(6)..write(obj.conditionIcon);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is WeatherModelAdapter && typeId == o.typeId;
}
