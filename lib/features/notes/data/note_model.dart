import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String body;
  @HiveField(3) List<String> tags;
  @HiveField(4) int colorLabel; // 0-5
  @HiveField(5) String? courseLink;
  @HiveField(6) bool isPinned;
  @HiveField(7) String? imagePath;
  @HiveField(8) String? linkedTaskId;
  @HiveField(9) bool isExported;
  @HiveField(10) DateTime createdAt;
  @HiveField(11) DateTime updatedAt;

  NoteModel({
    String? id,
    required this.title,
    this.body = '',
    List<String>? tags,
    this.colorLabel = 0,
    this.courseLink,
    this.isPinned = false,
    this.imagePath,
    this.linkedTaskId,
    this.isExported = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NoteModel copyWith({
    String? title,
    String? body,
    List<String>? tags,
    int? colorLabel,
    String? courseLink,
    bool? isPinned,
    String? imagePath,
    String? linkedTaskId,
    bool? isExported,
    DateTime? updatedAt,
  }) =>
      NoteModel(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        tags: tags ?? this.tags,
        colorLabel: colorLabel ?? this.colorLabel,
        courseLink: courseLink ?? this.courseLink,
        isPinned: isPinned ?? this.isPinned,
        imagePath: imagePath ?? this.imagePath,
        linkedTaskId: linkedTaskId ?? this.linkedTaskId,
        isExported: isExported ?? this.isExported,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'colorLabel': colorLabel,
        'courseLink': courseLink,
        'isPinned': isPinned,
        'imagePath': imagePath,
        'linkedTaskId': linkedTaskId,
        'isExported': isExported,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'],
        title: json['title'],
        body: json['body'] ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        colorLabel: json['colorLabel'] ?? 0,
        courseLink: json['courseLink'],
        isPinned: json['isPinned'] ?? false,
        imagePath: json['imagePath'],
        linkedTaskId: json['linkedTaskId'],
        isExported: json['isExported'] ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
            json['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}
