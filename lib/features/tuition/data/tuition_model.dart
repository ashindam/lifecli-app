import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'tuition_model.g.dart';

@HiveType(typeId: 9)
class TuitionStudentModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String subject;
  @HiveField(3) int monthlySalaryPaisa;
  @HiveField(4) int sessionsPerMonth;
  @HiveField(5) String contactNumber;
  @HiveField(6) int completedSessions;
  @HiveField(7) DateTime createdAt;

  TuitionStudentModel({
    String? id,
    required this.name,
    this.subject = '',
    this.monthlySalaryPaisa = 0,
    this.sessionsPerMonth = 0,
    this.contactNumber = '',
    this.completedSessions = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TuitionStudentModel copyWith({
    String? name,
    String? subject,
    int? monthlySalaryPaisa,
    int? sessionsPerMonth,
    String? contactNumber,
    int? completedSessions,
  }) =>
      TuitionStudentModel(
        id: id,
        name: name ?? this.name,
        subject: subject ?? this.subject,
        monthlySalaryPaisa: monthlySalaryPaisa ?? this.monthlySalaryPaisa,
        sessionsPerMonth: sessionsPerMonth ?? this.sessionsPerMonth,
        contactNumber: contactNumber ?? this.contactNumber,
        completedSessions: completedSessions ?? this.completedSessions,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject': subject,
        'monthlySalaryPaisa': monthlySalaryPaisa,
        'sessionsPerMonth': sessionsPerMonth,
        'contactNumber': contactNumber,
        'completedSessions': completedSessions,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory TuitionStudentModel.fromJson(Map<String, dynamic> json) =>
      TuitionStudentModel(
        id: json['id'],
        name: json['name'],
        subject: json['subject'] ?? '',
        monthlySalaryPaisa: json['monthlySalaryPaisa'] ?? 0,
        sessionsPerMonth: json['sessionsPerMonth'] ?? 0,
        contactNumber: json['contactNumber'] ?? '',
        completedSessions: json['completedSessions'] ?? 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}

@HiveType(typeId: 10)
class TuitionSessionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String studentId;
  @HiveField(2) DateTime date;
  @HiveField(3) bool isPresent;
  @HiveField(4) String note;

  TuitionSessionModel({
    String? id,
    required this.studentId,
    required this.date,
    this.isPresent = true,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  TuitionSessionModel copyWith({
    String? studentId,
    DateTime? date,
    bool? isPresent,
    String? note,
  }) =>
      TuitionSessionModel(
        id: id,
        studentId: studentId ?? this.studentId,
        date: date ?? this.date,
        isPresent: isPresent ?? this.isPresent,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'date': date.millisecondsSinceEpoch,
        'isPresent': isPresent,
        'note': note,
      };

  factory TuitionSessionModel.fromJson(Map<String, dynamic> json) =>
      TuitionSessionModel(
        id: json['id'],
        studentId: json['studentId'],
        date: DateTime.fromMillisecondsSinceEpoch(json['date']),
        isPresent: json['isPresent'] ?? true,
        note: json['note'] ?? '',
      );
}

@HiveType(typeId: 11)
class TuitionPaymentModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String studentId;
  @HiveField(2) int amountPaisa;
  @HiveField(3) String note;
  @HiveField(4) DateTime date;

  TuitionPaymentModel({
    String? id,
    required this.studentId,
    required this.amountPaisa,
    this.note = '',
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  TuitionPaymentModel copyWith({
    String? studentId,
    int? amountPaisa,
    String? note,
    DateTime? date,
  }) =>
      TuitionPaymentModel(
        id: id,
        studentId: studentId ?? this.studentId,
        amountPaisa: amountPaisa ?? this.amountPaisa,
        note: note ?? this.note,
        date: date ?? this.date,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'amountPaisa': amountPaisa,
        'note': note,
        'date': date.millisecondsSinceEpoch,
      };

  factory TuitionPaymentModel.fromJson(Map<String, dynamic> json) =>
      TuitionPaymentModel(
        id: json['id'],
        studentId: json['studentId'],
        amountPaisa: json['amountPaisa'] ?? 0,
        note: json['note'] ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(
            json['date'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}
