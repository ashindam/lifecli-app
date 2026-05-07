import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'notice_model.g.dart';

enum NoticeSource { department, hall, university, teacher }

@HiveType(typeId: 26)
class NoticeModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String body;
  @HiveField(3) int sourceTag; // NoticeSource index
  @HiveField(4) DateTime date;
  @HiveField(5) bool isPinned;
  @HiveField(6) bool isArchived;
  @HiveField(7) DateTime createdAt;

  NoticeModel({
    String? id, required this.title, required this.body,
    this.sourceTag = 2, DateTime? date, this.isPinned = false,
    this.isArchived = false, DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  NoticeSource get source => NoticeSource.values[sourceTag];
  String get sourceLabel => ['Department', 'Hall', 'University', 'Teacher'][sourceTag];
  String get sourceEmoji => ['🏛', '🏠', '🎓', '👨‍🏫'][sourceTag];

  NoticeModel copyWith({String? title, String? body, int? sourceTag,
    DateTime? date, bool? isPinned, bool? isArchived}) =>
    NoticeModel(id: id, title: title ?? this.title, body: body ?? this.body,
      sourceTag: sourceTag ?? this.sourceTag, date: date ?? this.date,
      isPinned: isPinned ?? this.isPinned, isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt);
}
