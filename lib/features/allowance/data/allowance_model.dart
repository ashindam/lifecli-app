import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'allowance_model.g.dart';

@HiveType(typeId: 6)
class AllowanceModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int monthlyAmountPaisa;
  @HiveField(2) int receivedDate; // day of month 1-31
  @HiveField(3) int savingsAmountPaisa;
  @HiveField(4) String month; // YYYY-MM
  @HiveField(5) DateTime createdAt;

  AllowanceModel({
    String? id,
    required this.monthlyAmountPaisa,
    this.receivedDate = 1,
    this.savingsAmountPaisa = 0,
    required this.month,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  AllowanceModel copyWith({
    int? monthlyAmountPaisa,
    int? receivedDate,
    int? savingsAmountPaisa,
    String? month,
  }) =>
      AllowanceModel(
        id: id,
        monthlyAmountPaisa: monthlyAmountPaisa ?? this.monthlyAmountPaisa,
        receivedDate: receivedDate ?? this.receivedDate,
        savingsAmountPaisa: savingsAmountPaisa ?? this.savingsAmountPaisa,
        month: month ?? this.month,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'monthlyAmountPaisa': monthlyAmountPaisa,
        'receivedDate': receivedDate,
        'savingsAmountPaisa': savingsAmountPaisa,
        'month': month,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AllowanceModel.fromJson(Map<String, dynamic> json) => AllowanceModel(
        id: json['id'],
        monthlyAmountPaisa: json['monthlyAmountPaisa'] ?? 0,
        receivedDate: json['receivedDate'] ?? 1,
        savingsAmountPaisa: json['savingsAmountPaisa'] ?? 0,
        month: json['month'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}
