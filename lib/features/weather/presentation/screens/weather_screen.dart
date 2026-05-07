import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../data/weather_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';

final _weatherProvider = StateNotifierProvider<_WeatherNotifier, _WeatherState>(
  (ref) => _WeatherNotifier(),
);

class _WeatherState {
  final WeatherModel? data;
  final List<DayForecast> forecasts;
  final bool isLoading;
  final String? error;
  const _WeatherState({this.data, this.forecasts = const [], this.isLoading = false, this.error});
  _WeatherState copyWith({WeatherModel? data, List<DayForecast>? forecasts, bool? isLoading, String? error}) =>
    _WeatherState(data: data ?? this.data, forecasts: forecasts ?? this.forecasts, isLoading: isLoading ?? this.isLoading, error: error);
}

class _WeatherNotifier extends StateNotifier<_WeatherState> {
  _WeatherNotifier() : super(const _WeatherState()) { _loadCached(); }

  void _loadCached() {
    final cached = HiveService.weather.get('current') as WeatherModel?;
    if (cached != null) state = state.copyWith(data: cached);
  }

  Future<void> fetch(String city) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = Dio();
      final res = await dio.get('https://wttr.in/$city?format=j1').timeout(const Duration(seconds: 10));
      final json = res.data as Map<String, dynamic>;
      final current = json['current_condition']?[0] ?? {};
      final weather = WeatherModel(
        city: city,
        condition: current['weatherDesc']?[0]?['value'] ?? 'Clear',
        tempC: double.tryParse(current['temp_C']?.toString() ?? '25') ?? 25,
        humidity: int.tryParse(current['humidity']?.toString() ?? '70') ?? 70,
        windKph: double.tryParse(current['windspeedKmph']?.toString() ?? '10') ?? 10,
        conditionIcon: _conditionEmoji(current['weatherDesc']?[0]?['value'] ?? ''),
      );
      await HiveService.weather.put('current', weather);
      state = state.copyWith(data: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not fetch weather. Showing cached data.');
    }
  }

  String _conditionEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain')) return '🌧';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('storm')) return '⛈';
    if (c.contains('fog') || c.contains('mist')) return '🌫';
    return '🌤';
  }
}

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});
  @override ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final _cityCtrl = TextEditingController(text: 'Chittagong');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(_weatherProvider.notifier).fetch('Chittagong'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_weatherProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Weather', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: RefreshIndicator(
        onRefresh: () => ref.read(_weatherProvider.notifier).fetch(_cityCtrl.text),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)))),
              const SizedBox(width: 12),
              FilledButton(onPressed: () => ref.read(_weatherProvider.notifier).fetch(_cityCtrl.text), child: const Text('Go')),
            ]),
            const SizedBox(height: 20),
            if (state.error != null) Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(12)),
              child: Text(state.error!, style: GoogleFonts.inter(fontSize: 13)),
            ),
            if (state.isLoading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            if (state.data != null) ...[
              _WeatherHeroCard(weather: state.data!),
              const SizedBox(height: 20),
              Row(children: [
                _StatCard('💧', 'Humidity', state.data!.humidityString),
                const SizedBox(width: 12),
                _StatCard('💨', 'Wind', state.data!.windString),
              ]),
              const SizedBox(height: 12),
              Text('Last updated: ${state.data!.fetchedAgoString}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeatherHeroCard extends StatelessWidget {
  final WeatherModel weather;
  const _WeatherHeroCard({required this.weather});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(children: [
      Text(weather.conditionIcon, style: const TextStyle(fontSize: 64)),
      const SizedBox(height: 8),
      Text(weather.tempString, style: GoogleFonts.inter(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(weather.condition, style: GoogleFonts.inter(fontSize: 16, color: Colors.white70)),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.location_on, size: 14, color: Colors.white60),
        const SizedBox(width: 4),
        Text(weather.city, style: GoogleFonts.inter(fontSize: 14, color: Colors.white60)),
      ]),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _StatCard(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      ]),
    ),
  );
}
