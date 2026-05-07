// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'bus_route_model.dart';

class BusRouteModelAdapter extends TypeAdapter<BusRouteModel> {
  @override final int typeId = 25;
  @override
  BusRouteModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return BusRouteModel(id: f[0], routeName: f[1] ?? '', university: f[2] ?? '',
        stops: (f[3] as List?)?.cast<String>() ?? [],
        departureTimes: (f[4] as List?)?.cast<String>() ?? [],
        alertMinutesBefore: f[5] ?? 15, isFavorite: f[6] ?? false);
  }
  @override
  void write(BinaryWriter writer, BusRouteModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.routeName)
      ..writeByte(2)..write(obj.university)..writeByte(3)..write(obj.stops)
      ..writeByte(4)..write(obj.departureTimes)..writeByte(5)..write(obj.alertMinutesBefore)
      ..writeByte(6)..write(obj.isFavorite);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is BusRouteModelAdapter && typeId == o.typeId;
}
