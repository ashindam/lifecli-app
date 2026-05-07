import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

enum TaskPriority { critical, high, medium, low, someday }
enum TaskStatus { pending, inProgress, onHold, completed, cancelled }
enum TaskType { academic, tuition, finance, personal, health, social }
enum TaskEnergy { highFocus, deepWork, easy, errands }
enum RepeatSchedule { none, daily, weekly, monthly, custom }

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String description;
  @HiveField(3) int priority; // TaskPriority index
  @HiveField(4) int status;   // TaskStatus index
  @HiveField(5) int type;     // TaskType index
  @HiveField(6) int energy;   // TaskEnergy index
  @HiveField(7) DateTime? dueDate;
  @HiveField(8) List<DateTime> reminders;
  @HiveField(9) int repeat;   // RepeatSchedule index
  @HiveField(10) int? customRepeatDays;
  @HiveField(11) DateTime createdAt;
  @HiveField(12) DateTime? completedAt;
  @HiveField(13) bool isPinned;
  @HiveField(14) String? linkedNoteId;
  @HiveField(15) String? parentTaskId; // for recurring instances

  TaskModel({
    String? id,
    required this.title,
    this.description = '',
    this.priority = 2, // medium
    this.status = 0,   // pending
    this.type = 3,     // personal
    this.energy = 2,   // easy
    this.dueDate,
    List<DateTime>? reminders,
    this.repeat = 0,
    this.customRepeatDays,
    DateTime? createdAt,
    this.completedAt,
    this.isPinned = false,
    this.linkedNoteId,
    this.parentTaskId,
  })  : id = id ?? const Uuid().v4(),
        reminders = reminders ?? [],
        createdAt = createdAt ?? DateTime.now();

  TaskPriority get priorityEnum => TaskPriority.values[priority];
  TaskStatus get statusEnum => TaskStatus.values[status];
  TaskType get typeEnum => TaskType.values[type];
  TaskEnergy get energyEnum => TaskEnergy.values[energy];
  RepeatSchedule get repeatEnum => RepeatSchedule.values[repeat];

  bool get isOverdue =>
      dueDate != null &&
      status != TaskStatus.completed.index &&
      status != TaskStatus.cancelled.index &&
      dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isNew =>
      DateTime.now().difference(createdAt).inHours < 24;

  String get priorityEmoji {
    switch (priorityEnum) {
      case TaskPriority.critical: return '🔴';
      case TaskPriority.high: return '🟠';
      case TaskPriority.medium: return '🟡';
      case TaskPriority.low: return '🟢';
      case TaskPriority.someday: return '⚪';
    }
  }

  String get statusEmoji {
    switch (statusEnum) {
      case TaskStatus.pending: return '🔵';
      case TaskStatus.inProgress: return '🔄';
      case TaskStatus.onHold: return '⏸️';
      case TaskStatus.completed: return '✅';
      case TaskStatus.cancelled: return '🚫';
    }
  }

  String get typeEmoji {
    switch (typeEnum) {
      case TaskType.academic: return '📚';
      case TaskType.tuition: return '💼';
      case TaskType.finance: return '💸';
      case TaskType.personal: return '🏠';
      case TaskType.health: return '🏃';
      case TaskType.social: return '🤝';
    }
  }

  String get energyEmoji {
    switch (energyEnum) {
      case TaskEnergy.highFocus: return '⚡';
      case TaskEnergy.deepWork: return '🧠';
      case TaskEnergy.easy: return '😌';
      case TaskEnergy.errands: return '📞';
    }
  }

  TaskModel copyWith({
    String? title,
    String? description,
    int? priority,
    int? status,
    int? type,
    int? energy,
    DateTime? dueDate,
    List<DateTime>? reminders,
    int? repeat,
    int? customRepeatDays,
    bool? isPinned,
    String? linkedNoteId,
    DateTime? completedAt,
  }) => TaskModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    type: type ?? this.type,
    energy: energy ?? this.energy,
    dueDate: dueDate ?? this.dueDate,
    reminders: reminders ?? this.reminders,
    repeat: repeat ?? this.repeat,
    customRepeatDays: customRepeatDays ?? this.customRepeatDays,
    createdAt: createdAt,
    completedAt: completedAt ?? this.completedAt,
    isPinned: isPinned ?? this.isPinned,
    linkedNoteId: linkedNoteId ?? this.linkedNoteId,
    parentTaskId: parentTaskId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority,
    'status': status,
    'type': type,
    'energy': energy,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'reminders': reminders.map((d) => d.millisecondsSinceEpoch).toList(),
    'repeat': repeat,
    'customRepeatDays': customRepeatDays,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
    'isPinned': isPinned,
    'linkedNoteId': linkedNoteId,
    'parentTaskId': parentTaskId,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    priority: json['priority'] ?? 2,
    status: json['status'] ?? 0,
    type: json['type'] ?? 3,
    energy: json['energy'] ?? 2,
    dueDate: json['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dueDate']) : null,
    reminders: (json['reminders'] as List?)
        ?.map((e) => DateTime.fromMillisecondsSinceEpoch(e as int))
        .toList() ?? [],
    repeat: json['repeat'] ?? 0,
    customRepeatDays: json['customRepeatDays'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    completedAt: json['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['completedAt']) : null,
    isPinned: json['isPinned'] ?? false,
    linkedNoteId: json['linkedNoteId'],
    parentTaskId: json['parentTaskId'],
  );
}
