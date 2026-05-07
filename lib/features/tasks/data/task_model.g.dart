// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      priority: fields[3] as int? ?? 2,
      status: fields[4] as int? ?? 0,
      type: fields[5] as int? ?? 3,
      energy: fields[6] as int? ?? 2,
      dueDate: fields[7] as DateTime?,
      reminders: (fields[8] as List?)?.cast<DateTime>() ?? [],
      repeat: fields[9] as int? ?? 0,
      customRepeatDays: fields[10] as int?,
      createdAt: fields[11] as DateTime?,
      completedAt: fields[12] as DateTime?,
      isPinned: fields[13] as bool? ?? false,
      linkedNoteId: fields[14] as String?,
      parentTaskId: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.energy)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.reminders)
      ..writeByte(9)
      ..write(obj.repeat)
      ..writeByte(10)
      ..write(obj.customRepeatDays)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.isPinned)
      ..writeByte(14)
      ..write(obj.linkedNoteId)
      ..writeByte(15)
      ..write(obj.parentTaskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
