import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'finance_model.g.dart';

enum FinanceType { loan, borrow } // loan = you lent money, borrow = you owe

@HiveType(typeId: 7)
class FinanceModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int type; // FinanceType index
  @HiveField(2) String contactName;
  @HiveField(3) int amountPaisa;
  @HiveField(4) String note;
  @HiveField(5) DateTime date;
  @HiveField(6) DateTime? dueDate;
  @HiveField(7) bool isSettled;
  @HiveField(8) DateTime? settledDate;
  @HiveField(9) DateTime createdAt;

  FinanceModel({
    String? id,
    this.type = 0,
    required this.contactName,
    required this.amountPaisa,
    this.note = '',
    DateTime? date,
    this.dueDate,
    this.isSettled = false,
    this.settledDate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  FinanceType get typeEnum => FinanceType.values[type];

  FinanceModel copyWith({
    int? type,
    String? contactName,
    int? amountPaisa,
    String? note,
    DateTime? date,
    DateTime? dueDate,
    bool? isSettled,
    DateTime? settledDate,
  }) =>
      FinanceModel(
        id: id,
        type: type ?? this.type,
        contactName: contactName ?? this.contactName,
        amountPaisa: amountPaisa ?? this.amountPaisa,
        note: note ?? this.note,
        date: date ?? this.date,
        dueDate: dueDate ?? this.dueDate,
        isSettled: isSettled ?? this.isSettled,
        settledDate: settledDate ?? this.settledDate,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'contactName': contactName,
        'amountPaisa': amountPaisa,
        'note': note,
        'date': date.millisecondsSinceEpoch,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'isSettled': isSettled,
        'settledDate': settledDate?.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory FinanceModel.fromJson(Map<String, dynamic> json) => FinanceModel(
        id: json['id'],
        type: json['type'] ?? 0,
        contactName: json['contactName'],
        amountPaisa: json['amountPaisa'] ?? 0,
        note: json['note'] ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(
            json['date'] ?? DateTime.now().millisecondsSinceEpoch),
        dueDate: json['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
            : null,
        isSettled: json['isSettled'] ?? false,
        settledDate: json['settledDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['settledDate'])
            : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}
