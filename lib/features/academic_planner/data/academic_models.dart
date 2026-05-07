import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'academic_models.g.dart';

@HiveType(typeId: 12)
class ClassEntryModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) List<int> dayOfWeek; // 1=Mon, 2=Tue, ...
  @HiveField(3) String startTime; // HH:mm
  @HiveField(4) String endTime;   // HH:mm
  @HiveField(5) String room;
  @HiveField(6) String teacherName;

  ClassEntryModel({
    String? id,
    required this.courseName,
    List<int>? dayOfWeek,
    this.startTime = '',
    this.endTime = '',
    this.room = '',
    this.teacherName = '',
  })  : id = id ?? const Uuid().v4(),
        dayOfWeek = dayOfWeek ?? [];

  ClassEntryModel copyWith({
    String? courseName,
    List<int>? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? teacherName,
  }) =>
      ClassEntryModel(
        id: id,
        courseName: courseName ?? this.courseName,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        room: room ?? this.room,
        teacherName: teacherName ?? this.teacherName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'teacherName': teacherName,
      };

  factory ClassEntryModel.fromJson(Map<String, dynamic> json) =>
      ClassEntryModel(
        id: json['id'],
        courseName: json['courseName'],
        dayOfWeek: (json['dayOfWeek'] as List?)?.cast<int>() ?? [],
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        room: json['room'] ?? '',
        teacherName: json['teacherName'] ?? '',
      );
}

// examType: 0=Midterm, 1=Final, 2=Quiz, 3=Lab
@HiveType(typeId: 13)
class ExamModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) DateTime date;
  @HiveField(3) String time;
  @HiveField(4) String venue;
  @HiveField(5) int examType; // 0=Midterm,1=Final,2=Quiz,3=Lab

  ExamModel({
    String? id,
    required this.courseName,
    required this.date,
    this.time = '',
    this.venue = '',
    this.examType = 0,
  }) : id = id ?? const Uuid().v4();

  ExamModel copyWith({
    String? courseName,
    DateTime? date,
    String? time,
    String? venue,
    int? examType,
  }) =>
      ExamModel(
        id: id,
        courseName: courseName ?? this.courseName,
        date: date ?? this.date,
        time: time ?? this.time,
        venue: venue ?? this.venue,
        examType: examType ?? this.examType,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'date': date.millisecondsSinceEpoch,
        'time': time,
        'venue': venue,
        'examType': examType,
      };

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'],
        courseName: json['courseName'],
        date: DateTime.fromMillisecondsSinceEpoch(json['date']),
        time: json['time'] ?? '',
        venue: json['venue'] ?? '',
        examType: json['examType'] ?? 0,
      );
}

// submissionType: custom int (e.g. 0=Online, 1=Physical)
// status: 0=Pending, 1=InProgress, 2=Submitted, 3=Graded
@HiveType(typeId: 14)
class AssignmentModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) String title;
  @HiveField(3) double weightage;
  @HiveField(4) DateTime dueDate;
  @HiveField(5) int submissionType;
  @HiveField(6) int status; // 0-3

  AssignmentModel({
    String? id,
    required this.courseName,
    required this.title,
    this.weightage = 0.0,
    required this.dueDate,
    this.submissionType = 0,
    this.status = 0,
  }) : id = id ?? const Uuid().v4();

  AssignmentModel copyWith({
    String? courseName,
    String? title,
    double? weightage,
    DateTime? dueDate,
    int? submissionType,
    int? status,
  }) =>
      AssignmentModel(
        id: id,
        courseName: courseName ?? this.courseName,
        title: title ?? this.title,
        weightage: weightage ?? this.weightage,
        dueDate: dueDate ?? this.dueDate,
        submissionType: submissionType ?? this.submissionType,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'title': title,
        'weightage': weightage,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'submissionType': submissionType,
        'status': status,
      };

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      AssignmentModel(
        id: json['id'],
        courseName: json['courseName'],
        title: json['title'],
        weightage: (json['weightage'] as num?)?.toDouble() ?? 0.0,
        dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
        submissionType: json['submissionType'] ?? 0,
        status: json['status'] ?? 0,
      );
}

@HiveType(typeId: 15)
class AttendanceRecord extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) DateTime date;
  @HiveField(3) bool isPresent;
  @HiveField(4) double minimumPercent;

  AttendanceRecord({
    String? id,
    required this.courseName,
    required this.date,
    this.isPresent = true,
    this.minimumPercent = 75.0,
  }) : id = id ?? const Uuid().v4();

  AttendanceRecord copyWith({
    String? courseName,
    DateTime? date,
    bool? isPresent,
    double? minimumPercent,
  }) =>
      AttendanceRecord(
        id: id,
        courseName: courseName ?? this.courseName,
        date: date ?? this.date,
        isPresent: isPresent ?? this.isPresent,
        minimumPercent: minimumPercent ?? this.minimumPercent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'date': date.millisecondsSinceEpoch,
        'isPresent': isPresent,
        'minimumPercent': minimumPercent,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'],
        courseName: json['courseName'],
        date: DateTime.fromMillisecondsSinceEpoch(json['date']),
        isPresent: json['isPresent'] ?? true,
        minimumPercent: (json['minimumPercent'] as num?)?.toDouble() ?? 75.0,
      );
}
