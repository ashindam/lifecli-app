import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'study_session_model.g.dart';

@HiveType(typeId: 21)
class StudySessionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String subject;
  @HiveField(2) int durationMinutes;
  @HiveField(3) DateTime date;
  @HiveField(4) String notes;
  @HiveField(5) List<String> topicsCovered;
  @HiveField(6) bool fromPomodoro;

  StudySessionModel({
    String? id,
    required this.subject,
    this.durationMinutes = 0,
    DateTime? date,
    this.notes = '',
    List<String>? topicsCovered,
    this.fromPomodoro = false,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        topicsCovered = topicsCovered ?? [];

  StudySessionModel copyWith({
    String? subject,
    int? durationMinutes,
    DateTime? date,
    String? notes,
    List<String>? topicsCovered,
    bool? fromPomodoro,
  }) =>
      StudySessionModel(
        id: id,
        subject: subject ?? this.subject,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        topicsCovered: topicsCovered ?? this.topicsCovered,
        fromPomodoro: fromPomodoro ?? this.fromPomodoro,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'durationMinutes': durationMinutes,
        'date': date.millisecondsSinceEpoch,
        'notes': notes,
        'topicsCovered': topicsCovered,
        'fromPomodoro': fromPomodoro,
      };

  factory StudySessionModel.fromJson(Map<String, dynamic> json) =>
      StudySessionModel(
        id: json['id'],
        subject: json['subject'],
        durationMinutes: json['durationMinutes'] ?? 0,
        date: DateTime.fromMillisecondsSinceEpoch(
            json['date'] ?? DateTime.now().millisecondsSinceEpoch),
        notes: json['notes'] ?? '',
        topicsCovered:
            (json['topicsCovered'] as List?)?.cast<String>() ?? [],
        fromPomodoro: json['fromPomodoro'] ?? false,
      );
}
