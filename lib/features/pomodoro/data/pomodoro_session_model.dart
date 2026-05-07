import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'pomodoro_session_model.g.dart';

@HiveType(typeId: 22)
class PomodoroSessionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int type; // 0=work,1=shortBreak,2=longBreak,3=custom
  @HiveField(2) int durationMinutes;
  @HiveField(3) String subject;
  @HiveField(4) DateTime completedAt;
  @HiveField(5) String label;

  PomodoroSessionModel({
    String? id,
    required this.type,
    required this.durationMinutes,
    this.subject = '',
    DateTime? completedAt,
    this.label = '',
  })  : id = id ?? const Uuid().v4(),
        completedAt = completedAt ?? DateTime.now();

  String get typeName {
    switch (type) {
      case 0: return 'Pomodoro';
      case 1: return 'Short Break';
      case 2: return 'Long Break';
      default: return label.isNotEmpty ? label : 'Custom';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'durationMinutes': durationMinutes,
    'subject': subject, 'completedAt': completedAt.millisecondsSinceEpoch, 'label': label,
  };

  factory PomodoroSessionModel.fromJson(Map<String, dynamic> j) => PomodoroSessionModel(
    id: j['id'], type: j['type'] ?? 0, durationMinutes: j['durationMinutes'] ?? 25,
    subject: j['subject'] ?? '', label: j['label'] ?? '',
    completedAt: j['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(j['completedAt']) : DateTime.now(),
  );
}
