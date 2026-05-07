import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reading_item_model.g.dart';

enum ReadingStatus { unread, inProgress, done }
enum ReadingType { youtube, pdf, book, article }

@HiveType(typeId: 31)
class ReadingItemModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String? url;
  @HiveField(3) String? courseLink;
  @HiveField(4) int type; // ReadingType index
  @HiveField(5) int status; // ReadingStatus index
  @HiveField(6) DateTime createdAt;

  ReadingItemModel({
    String? id, required this.title, this.url, this.courseLink,
    this.type = 3, this.status = 0, DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ReadingStatus get statusEnum => ReadingStatus.values[status];
  ReadingType get typeEnum => ReadingType.values[type];

  String get typeEmoji => ['▶️', '📄', '📗', '🔗'][type];
  String get typeLabel => ['YouTube', 'PDF', 'Book', 'Article'][type];
  String get statusEmoji => ['📖', '🔄', '✅'][status];
  String get statusLabel => ['Unread', 'In Progress', 'Done'][status];

  ReadingItemModel copyWith({String? title, String? url, String? courseLink,
    int? type, int? status}) =>
    ReadingItemModel(id: id, title: title ?? this.title, url: url ?? this.url,
      courseLink: courseLink ?? this.courseLink, type: type ?? this.type,
      status: status ?? this.status, createdAt: createdAt);

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'url': url, 'courseLink': courseLink,
    'type': type, 'status': status, 'createdAt': createdAt.millisecondsSinceEpoch,
  };
}
