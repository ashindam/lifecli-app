import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'inbox_item_model.g.dart';

enum InboxStatus { unprocessed, converted, discarded }

@HiveType(typeId: 28)
class InboxItemModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String content;
  @HiveField(2) DateTime createdAt;
  @HiveField(3) int status; // InboxStatus index
  @HiveField(4) String? convertedTo;

  InboxItemModel({
    String? id, required this.content, DateTime? createdAt,
    this.status = 0, this.convertedTo,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  InboxStatus get statusEnum => InboxStatus.values[status];

  InboxItemModel copyWith({String? content, int? status, String? convertedTo}) =>
    InboxItemModel(id: id, content: content ?? this.content, createdAt: createdAt,
      status: status ?? this.status, convertedTo: convertedTo ?? this.convertedTo);

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'createdAt': createdAt.millisecondsSinceEpoch,
    'status': status, 'convertedTo': convertedTo,
  };
}
