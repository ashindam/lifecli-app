import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

// recurringType: 0=none, 1=monthly, 2=weekly
@HiveType(typeId: 4)
class ExpenseModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int amountPaisa;
  @HiveField(2) String category;
  @HiveField(3) String note;
  @HiveField(4) DateTime date;
  @HiveField(5) bool isRecurring;
  @HiveField(6) int recurringType; // 0=none, 1=monthly, 2=weekly

  ExpenseModel({
    String? id,
    required this.amountPaisa,
    this.category = '',
    this.note = '',
    DateTime? date,
    this.isRecurring = false,
    this.recurringType = 0,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  ExpenseModel copyWith({
    int? amountPaisa,
    String? category,
    String? note,
    DateTime? date,
    bool? isRecurring,
    int? recurringType,
  }) =>
      ExpenseModel(
        id: id,
        amountPaisa: amountPaisa ?? this.amountPaisa,
        category: category ?? this.category,
        note: note ?? this.note,
        date: date ?? this.date,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringType: recurringType ?? this.recurringType,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountPaisa': amountPaisa,
        'category': category,
        'note': note,
        'date': date.millisecondsSinceEpoch,
        'isRecurring': isRecurring,
        'recurringType': recurringType,
      };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'],
        amountPaisa: json['amountPaisa'] ?? 0,
        category: json['category'] ?? '',
        note: json['note'] ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(
            json['date'] ?? DateTime.now().millisecondsSinceEpoch),
        isRecurring: json['isRecurring'] ?? false,
        recurringType: json['recurringType'] ?? 0,
      );
}

@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  @HiveField(0) String category;
  @HiveField(1) int monthlyLimitPaisa;

  BudgetModel({
    required this.category,
    required this.monthlyLimitPaisa,
  });

  BudgetModel copyWith({
    String? category,
    int? monthlyLimitPaisa,
  }) =>
      BudgetModel(
        category: category ?? this.category,
        monthlyLimitPaisa: monthlyLimitPaisa ?? this.monthlyLimitPaisa,
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'monthlyLimitPaisa': monthlyLimitPaisa,
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        category: json['category'],
        monthlyLimitPaisa: json['monthlyLimitPaisa'] ?? 0,
      );
}
