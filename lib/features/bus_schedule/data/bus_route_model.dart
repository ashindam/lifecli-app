import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bus_route_model.g.dart';

@HiveType(typeId: 25)
class BusRouteModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String routeName;
  @HiveField(2) String university;
  @HiveField(3) List<String> stops;
  @HiveField(4) List<String> departureTimes; // HH:mm
  @HiveField(5) int alertMinutesBefore;
  @HiveField(6) bool isFavorite;

  BusRouteModel({
    String? id, required this.routeName, this.university = '',
    List<String>? stops, List<String>? departureTimes,
    this.alertMinutesBefore = 15, this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        stops = stops ?? [],
        departureTimes = departureTimes ?? [];

  /// Next departure from now
  String? get nextDeparture {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    for (final t in departureTimes) {
      final parts = t.split(':');
      final tMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (tMins > nowMins) return t;
    }
    return departureTimes.isNotEmpty ? departureTimes.first : null; // wraps to first
  }

  int? get minutesUntilNext {
    final next = nextDeparture;
    if (next == null) return null;
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    final parts = next.split(':');
    var tMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    if (tMins < nowMins) tMins += 24 * 60; // next day
    return tMins - nowMins;
  }

  BusRouteModel copyWith({String? routeName, String? university, List<String>? stops,
    List<String>? departureTimes, int? alertMinutesBefore, bool? isFavorite}) =>
    BusRouteModel(id: id, routeName: routeName ?? this.routeName, university: university ?? this.university,
      stops: stops ?? this.stops, departureTimes: departureTimes ?? this.departureTimes,
      alertMinutesBefore: alertMinutesBefore ?? this.alertMinutesBefore,
      isFavorite: isFavorite ?? this.isFavorite);
}
