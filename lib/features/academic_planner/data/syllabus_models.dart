import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'syllabus_models.g.dart';

// status: 0=NotStarted, 1=Studying, 2=Covered
@HiveType(typeId: 16)
class SyllabusTopicModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseId;
  @HiveField(2) String topicName;
  @HiveField(3) int status; // 0=NotStarted,1=Studying,2=Covered
  @HiveField(4) bool isStarred;
  @HiveField(5) List<String> linkedStudySessionIds;

  SyllabusTopicModel({
    String? id,
    required this.courseId,
    required this.topicName,
    this.status = 0,
    this.isStarred = false,
    List<String>? linkedStudySessionIds,
  })  : id = id ?? const Uuid().v4(),
        linkedStudySessionIds = linkedStudySessionIds ?? [];

  SyllabusTopicModel copyWith({
    String? courseId,
    String? topicName,
    int? status,
    bool? isStarred,
    List<String>? linkedStudySessionIds,
  }) =>
      SyllabusTopicModel(
        id: id,
        courseId: courseId ?? this.courseId,
        topicName: topicName ?? this.topicName,
        status: status ?? this.status,
        isStarred: isStarred ?? this.isStarred,
        linkedStudySessionIds:
            linkedStudySessionIds ?? this.linkedStudySessionIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'topicName': topicName,
        'status': status,
        'isStarred': isStarred,
        'linkedStudySessionIds': linkedStudySessionIds,
      };

  factory SyllabusTopicModel.fromJson(Map<String, dynamic> json) =>
      SyllabusTopicModel(
        id: json['id'],
        courseId: json['courseId'],
        topicName: json['topicName'],
        status: json['status'] ?? 0,
        isStarred: json['isStarred'] ?? false,
        linkedStudySessionIds:
            (json['linkedStudySessionIds'] as List?)?.cast<String>() ?? [],
      );
}

@HiveType(typeId: 17)
class SyllabusCourseModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) List<SyllabusTopicModel> topics;

  SyllabusCourseModel({
    String? id,
    required this.courseName,
    List<SyllabusTopicModel>? topics,
  })  : id = id ?? const Uuid().v4(),
        topics = topics ?? [];

  SyllabusCourseModel copyWith({
    String? courseName,
    List<SyllabusTopicModel>? topics,
  }) =>
      SyllabusCourseModel(
        id: id,
        courseName: courseName ?? this.courseName,
        topics: topics ?? this.topics,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'topics': topics.map((t) => t.toJson()).toList(),
      };

  factory SyllabusCourseModel.fromJson(Map<String, dynamic> json) =>
      SyllabusCourseModel(
        id: json['id'],
        courseName: json['courseName'],
        topics: (json['topics'] as List?)
                ?.map((e) =>
                    SyllabusTopicModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
