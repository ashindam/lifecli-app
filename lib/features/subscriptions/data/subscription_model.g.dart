// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'subscription_model.dart';

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override final int typeId = 24;
  @override
  SubscriptionModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return SubscriptionModel(id: f[0], name: f[1] ?? '', amountPaisa: f[2] ?? 0,
        renewalDate: f[3] ?? DateTime.now(), category: f[4] ?? 'Other',
        operator_: f[5], isActive: f[6] ?? true, lastRenewedDate: f[7]);
  }
  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer..writeByte(8)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.amountPaisa)..writeByte(3)..write(obj.renewalDate)
      ..writeByte(4)..write(obj.category)..writeByte(5)..write(obj.operator_)
      ..writeByte(6)..write(obj.isActive)..writeByte(7)..write(obj.lastRenewedDate);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is SubscriptionModelAdapter && typeId == o.typeId;
}
