import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 2)
class HabitModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String category;
  @HiveField(3) int currentStreak;
  @HiveField(4) int longestStreak;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime? reminderTime;
  @HiveField(7) bool isActive;

  HabitModel({
    String? id,
    required this.name,
    this.category = '',
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? createdAt,
    this.reminderTime,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  HabitModel copyWith({
    String? name,
    String? category,
    int? currentStreak,
    int? longestStreak,
    DateTime? reminderTime,
    bool? isActive,
  }) =>
      HabitModel(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        createdAt: createdAt,
        reminderTime: reminderTime ?? this.reminderTime,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'reminderTime': reminderTime?.millisecondsSinceEpoch,
        'isActive': isActive,
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'],
        name: json['name'],
        category: json['category'] ?? '',
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
        reminderTime: json['reminderTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['reminderTime'])
            : null,
        isActive: json['isActive'] ?? true,
      );
}

@HiveType(typeId: 3)
class HabitLogModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String habitId;
  @HiveField(2) DateTime date;
  @HiveField(3) bool isCheckedIn;

  HabitLogModel({
    String? id,
    required this.habitId,
    required this.date,
    this.isCheckedIn = false,
  }) : id = id ?? const Uuid().v4();

  HabitLogModel copyWith({
    String? habitId,
    DateTime? date,
    bool? isCheckedIn,
  }) =>
      HabitLogModel(
        id: id,
        habitId: habitId ?? this.habitId,
        date: date ?? this.date,
        isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date.millisecondsSinceEpoch,
        'isCheckedIn': isCheckedIn,
      };

  factory HabitLogModel.fromJson(Map<String, dynamic> json) => HabitLogModel(
        id: json['id'],
        habitId: json['habitId'],
        date: DateTime.fromMillisecondsSinceEpoch(json['date']),
        isCheckedIn: json['isCheckedIn'] ?? false,
      );
}
