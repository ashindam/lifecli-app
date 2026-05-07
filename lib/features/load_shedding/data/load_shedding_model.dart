import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'load_shedding_model.g.dart';

@HiveType(typeId: 27)
class LoadSheddingSlot extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int dayOfWeek; // 1=Mon..7=Sun
  @HiveField(2) String startTime; // HH:mm
  @HiveField(3) String endTime;
  @HiveField(4) String area;
  @HiveField(5) bool isEnabled;

  LoadSheddingSlot({
    String? id, required this.dayOfWeek, required this.startTime,
    required this.endTime, this.area = 'My Area', this.isEnabled = true,
  }) : id = id ?? const Uuid().v4();

  String get dayName => ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayOfWeek];
  String get timeRange => '$startTime – $endTime';

  bool get isActiveToday {
    final now = DateTime.now();
    return isEnabled && now.weekday == dayOfWeek;
  }

  bool isCurrentlyActive() {
    if (!isActiveToday) return false;
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    final sParts = startTime.split(':');
    final eParts = endTime.split(':');
    final startMins = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
    final endMins = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);
    return nowMins >= startMins && nowMins < endMins;
  }

  LoadSheddingSlot copyWith({int? dayOfWeek, String? startTime, String? endTime,
    String? area, bool? isEnabled}) =>
    LoadSheddingSlot(id: id, dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime,
      area: area ?? this.area, isEnabled: isEnabled ?? this.isEnabled);
}
