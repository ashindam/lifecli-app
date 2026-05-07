import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'grade_models.g.dart';

@HiveType(typeId: 18)
class GradeComponent extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) double weightagePercent;
  @HiveField(2) double? marksObtained;
  @HiveField(3) double totalMarks;

  GradeComponent({
    required this.name,
    required this.weightagePercent,
    this.marksObtained,
    this.totalMarks = 100.0,
  });

  GradeComponent copyWith({
    String? name,
    double? weightagePercent,
    double? marksObtained,
    double? totalMarks,
  }) =>
      GradeComponent(
        name: name ?? this.name,
        weightagePercent: weightagePercent ?? this.weightagePercent,
        marksObtained: marksObtained ?? this.marksObtained,
        totalMarks: totalMarks ?? this.totalMarks,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'weightagePercent': weightagePercent,
        'marksObtained': marksObtained,
        'totalMarks': totalMarks,
      };

  factory GradeComponent.fromJson(Map<String, dynamic> json) => GradeComponent(
        name: json['name'],
        weightagePercent:
            (json['weightagePercent'] as num?)?.toDouble() ?? 0.0,
        marksObtained: (json['marksObtained'] as num?)?.toDouble(),
        totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? 100.0,
      );
}

@HiveType(typeId: 19)
class GradeCourseModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseName;
  @HiveField(2) int creditHours;
  @HiveField(3) List<GradeComponent> components;
  @HiveField(4) String semesterId;

  GradeCourseModel({
    String? id,
    required this.courseName,
    this.creditHours = 3,
    List<GradeComponent>? components,
    required this.semesterId,
  })  : id = id ?? const Uuid().v4(),
        components = components ?? [];

  GradeCourseModel copyWith({
    String? courseName,
    int? creditHours,
    List<GradeComponent>? components,
    String? semesterId,
  }) =>
      GradeCourseModel(
        id: id,
        courseName: courseName ?? this.courseName,
        creditHours: creditHours ?? this.creditHours,
        components: components ?? this.components,
        semesterId: semesterId ?? this.semesterId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'creditHours': creditHours,
        'components': components.map((c) => c.toJson()).toList(),
        'semesterId': semesterId,
      };

  factory GradeCourseModel.fromJson(Map<String, dynamic> json) =>
      GradeCourseModel(
        id: json['id'],
        courseName: json['courseName'],
        creditHours: json['creditHours'] ?? 3,
        components: (json['components'] as List?)
                ?.map((e) =>
                    GradeComponent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        semesterId: json['semesterId'],
      );
}

@HiveType(typeId: 20)
class SemesterModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name; // e.g. "Spring 2024"
  @HiveField(2) List<GradeCourseModel> courses;

  SemesterModel({
    String? id,
    required this.name,
    List<GradeCourseModel>? courses,
  })  : id = id ?? const Uuid().v4(),
        courses = courses ?? [];

  SemesterModel copyWith({
    String? name,
    List<GradeCourseModel>? courses,
  }) =>
      SemesterModel(
        id: id,
        name: name ?? this.name,
        courses: courses ?? this.courses,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'courses': courses.map((c) => c.toJson()).toList(),
      };

  factory SemesterModel.fromJson(Map<String, dynamic> json) => SemesterModel(
        id: json['id'],
        name: json['name'],
        courses: (json['courses'] as List?)
                ?.map((e) =>
                    GradeCourseModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
