import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bill_split_model.g.dart';

// ParticipantModel is a plain Dart class (not a HiveObject).
// It is serialized as a Map<String,dynamic> inside BillSplitModel's Hive adapter.
class ParticipantModel {
  final String name;
  final int amountPaisa;
  final bool hasPaid;

  const ParticipantModel({
    required this.name,
    this.amountPaisa = 0,
    this.hasPaid = false,
  });

  ParticipantModel copyWith({
    String? name,
    int? amountPaisa,
    bool? hasPaid,
  }) =>
      ParticipantModel(
        name: name ?? this.name,
        amountPaisa: amountPaisa ?? this.amountPaisa,
        hasPaid: hasPaid ?? this.hasPaid,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'amountPaisa': amountPaisa,
        'hasPaid': hasPaid,
      };

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      ParticipantModel(
        name: json['name'] as String,
        amountPaisa: json['amountPaisa'] as int? ?? 0,
        hasPaid: json['hasPaid'] as bool? ?? false,
      );
}

@HiveType(typeId: 8)
class BillSplitModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) int totalAmountPaisa;
  // Participants stored as List<Map> in Hive (serialized manually in adapter)
  @HiveField(3) List<Map> participantsRaw;
  @HiveField(4) bool isEqualSplit;
  @HiveField(5) DateTime date;
  @HiveField(6) DateTime createdAt;

  BillSplitModel({
    String? id,
    required this.title,
    required this.totalAmountPaisa,
    List<Map>? participantsRaw,
    this.isEqualSplit = true,
    DateTime? date,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        participantsRaw = participantsRaw ?? [],
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  List<ParticipantModel> get participants => participantsRaw
      .map((e) => ParticipantModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  set participants(List<ParticipantModel> value) {
    participantsRaw = value.map((p) => p.toJson()).toList();
  }

  BillSplitModel copyWith({
    String? title,
    int? totalAmountPaisa,
    List<ParticipantModel>? participants,
    bool? isEqualSplit,
    DateTime? date,
  }) {
    final copy = BillSplitModel(
      id: id,
      title: title ?? this.title,
      totalAmountPaisa: totalAmountPaisa ?? this.totalAmountPaisa,
      participantsRaw: participantsRaw,
      isEqualSplit: isEqualSplit ?? this.isEqualSplit,
      date: date ?? this.date,
      createdAt: createdAt,
    );
    if (participants != null) copy.participants = participants;
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalAmountPaisa': totalAmountPaisa,
        'participants': participants.map((p) => p.toJson()).toList(),
        'isEqualSplit': isEqualSplit,
        'date': date.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory BillSplitModel.fromJson(Map<String, dynamic> json) {
    final model = BillSplitModel(
      id: json['id'],
      title: json['title'],
      totalAmountPaisa: json['totalAmountPaisa'] ?? 0,
      isEqualSplit: json['isEqualSplit'] ?? true,
      date: DateTime.fromMillisecondsSinceEpoch(
          json['date'] ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
    model.participants = (json['participants'] as List?)
            ?.map((e) =>
                ParticipantModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return model;
  }
}
