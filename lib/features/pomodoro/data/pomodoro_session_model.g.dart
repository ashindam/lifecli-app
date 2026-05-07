// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'pomodoro_session_model.dart';

class PomodoroSessionModelAdapter extends TypeAdapter<PomodoroSessionModel> {
  @override final int typeId = 22;
  @override
  PomodoroSessionModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return PomodoroSessionModel(id: f[0], type: f[1] ?? 0, durationMinutes: f[2] ?? 25,
        subject: f[3] ?? '', completedAt: f[4], label: f[5] ?? '');
  }
  @override
  void write(BinaryWriter writer, PomodoroSessionModel obj) {
    writer..writeByte(6)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.type)
      ..writeByte(2)..write(obj.durationMinutes)..writeByte(3)..write(obj.subject)
      ..writeByte(4)..write(obj.completedAt)..writeByte(5)..write(obj.label);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is PomodoroSessionModelAdapter && typeId == o.typeId;
}
