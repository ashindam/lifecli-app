import 'package:hive/hive.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 23)
class WeatherModel extends HiveObject {
  @HiveField(0) String city;
  @HiveField(1) String condition;
  @HiveField(2) double tempC;
  @HiveField(3) int humidity;
  @HiveField(4) double windKph;
  @HiveField(5) DateTime fetchedAt;
  @HiveField(6) String conditionIcon; // emoji or icon code

  WeatherModel({
    required this.city, required this.condition, required this.tempC,
    required this.humidity, required this.windKph, DateTime? fetchedAt,
    this.conditionIcon = '🌤',
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  String get tempString => '${tempC.round()}°C';
  String get humidityString => '$humidity%';
  String get windString => '${windKph.round()} km/h';
  String get fetchedAgoString {
    final diff = DateTime.now().difference(fetchedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class DayForecast {
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final String condition;
  final String emoji;

  const DayForecast({
    required this.date, required this.maxTempC, required this.minTempC,
    required this.condition, this.emoji = '🌤',
  });

  factory DayForecast.fromWttr(Map<String, dynamic> json) {
    final maxC = double.tryParse(json['maxtempC']?.toString() ?? '0') ?? 0;
    final minC = double.tryParse(json['mintempC']?.toString() ?? '0') ?? 0;
    final desc = (json['hourly'] as List?)?.first['weatherDesc']?.first?['value'] ?? 'Clear';
    return DayForecast(date: DateTime.now(), maxTempC: maxC, minTempC: minC, condition: desc);
  }
}
