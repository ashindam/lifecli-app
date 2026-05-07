import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 24)
class SubscriptionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) int amountPaisa;
  @HiveField(3) DateTime renewalDate;
  @HiveField(4) String category;
  @HiveField(5) String? operator_;
  @HiveField(6) bool isActive;
  @HiveField(7) DateTime? lastRenewedDate;

  SubscriptionModel({
    String? id, required this.name, required this.amountPaisa,
    required this.renewalDate, this.category = 'Other', this.operator_,
    this.isActive = true, this.lastRenewedDate,
  }) : id = id ?? const Uuid().v4();

  int get daysUntilRenewal {
    final today = DateTime.now();
    final d = DateTime(renewalDate.year, renewalDate.month, renewalDate.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.difference(t).inDays;
  }

  SubscriptionModel copyWith({String? name, int? amountPaisa, DateTime? renewalDate,
    String? category, String? operator_, bool? isActive, DateTime? lastRenewedDate}) =>
    SubscriptionModel(id: id, name: name ?? this.name, amountPaisa: amountPaisa ?? this.amountPaisa,
      renewalDate: renewalDate ?? this.renewalDate, category: category ?? this.category,
      operator_: operator_ ?? this.operator_, isActive: isActive ?? this.isActive,
      lastRenewedDate: lastRenewedDate ?? this.lastRenewedDate);

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'amountPaisa': amountPaisa,
    'renewalDate': renewalDate.millisecondsSinceEpoch, 'category': category,
    'operator': operator_, 'isActive': isActive,
    'lastRenewedDate': lastRenewedDate?.millisecondsSinceEpoch,
  };
}
