import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'health_log_model.g.dart';

@HiveType(typeId: 30)
class HealthLogModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime date;
  @HiveField(2) double sleepHours;
  @HiveField(3) int waterGlasses;
  @HiveField(4) int mood; // 0=😩 1=😐 2=🙂 3=😊 4=🤩
  @HiveField(5) String note;
  @HiveField(6) DateTime createdAt;

  HealthLogModel({
    String? id, DateTime? date, this.sleepHours = 7, this.waterGlasses = 0,
    this.mood = 2, this.note = '', DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  static const List<String> moodEmojis = ['😩', '😐', '🙂', '😊', '🤩'];
  static const List<String> moodLabels = ['Terrible', 'Okay', 'Good', 'Happy', 'Amazing'];

  String get moodEmoji => moodEmojis[mood.clamp(0, 4)];
  String get moodLabel => moodLabels[mood.clamp(0, 4)];

  HealthLogModel copyWith({double? sleepHours, int? waterGlasses, int? mood, String? note}) =>
    HealthLogModel(id: id, date: date, sleepHours: sleepHours ?? this.sleepHours,
      waterGlasses: waterGlasses ?? this.waterGlasses, mood: mood ?? this.mood,
      note: note ?? this.note, createdAt: createdAt);

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.millisecondsSinceEpoch, 'sleepHours': sleepHours,
    'waterGlasses': waterGlasses, 'mood': mood, 'note': note,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}
