import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/health_log_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';

final _healthProvider = StateNotifierProvider<_HealthNotifier, List<HealthLogModel>>(
  (ref) => _HealthNotifier(),
);

class _HealthNotifier extends StateNotifier<List<HealthLogModel>> {
  _HealthNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.healthLogs.values.whereType<HealthLogModel>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  Future<void> saveLog(HealthLogModel log) async {
    // Remove existing log for same day
    final existing = state.where((l) => DateHelpers.isSameDay(l.date, log.date)).toList();
    for (final e in existing) await HiveService.healthLogs.delete(e.id);
    await HiveService.healthLogs.put(log.id, log);
    _load();
  }
  HealthLogModel? todayLog() {
    final today = DateTime.now();
    try { return state.firstWhere((l) => DateHelpers.isSameDay(l.date, today)); }
    catch (_) { return null; }
  }
}

class HealthLogScreen extends ConsumerStatefulWidget {
  const HealthLogScreen({super.key});
  @override ConsumerState<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends ConsumerState<HealthLogScreen> {
  double _sleep = 7;
  int _water = 0;
  int _mood = 2;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = ref.read(_healthProvider.notifier).todayLog();
      if (today != null) {
        setState(() {
          _sleep = today.sleepHours; _water = today.waterGlasses;
          _mood = today.mood; _noteCtrl.text = today.note;
        });
      }
    });
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    await ref.read(_healthProvider.notifier).saveLog(HealthLogModel(
      sleepHours: _sleep, waterGlasses: _water, mood: _mood, note: _noteCtrl.text.trim(),
    ));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Health log saved!')));
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(_healthProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Health Log', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [TextButton(onPressed: _save, child: const Text('Save Today'))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Today's Check-in", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          // Sleep
          _SectionCard(
            emoji: '😴', title: 'Sleep',
            child: Column(children: [
              Text('${_sleep.toStringAsFixed(1)} hours', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
              Slider(value: _sleep, min: 0, max: 12, divisions: 24, label: '${_sleep.toStringAsFixed(1)}h',
                onChanged: (v) => setState(() => _sleep = v), activeColor: AppColors.primary),
            ]),
          ),
          const SizedBox(height: 14),
          // Water
          _SectionCard(
            emoji: '💧', title: 'Water Intake',
            child: Column(children: [
              Text('$_water glasses', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.info)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: List.generate(10, (i) => GestureDetector(
                  onTap: () => setState(() => _water = i + 1 == _water ? i : i + 1),
                  child: Icon(Icons.water_drop, size: 32, color: i < _water ? AppColors.info : AppColors.primaryContainer),
                )),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          // Mood
          _SectionCard(
            emoji: '🧠', title: 'Mood',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _mood = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: i == _mood ? AppColors.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(HealthLogModel.moodEmojis[i], style: TextStyle(fontSize: i == _mood ? 36 : 28)),
                ),
              )),
            ),
          ),
          const SizedBox(height: 14),
          TextField(controller: _noteCtrl, maxLines: 3,
            decoration: const InputDecoration(labelText: 'Optional note', hintText: 'How are you feeling today?')),
          const SizedBox(height: 32),
          if (logs.isNotEmpty) ...[
            Text('Recent Logs', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...logs.take(7).map((log) => ListTile(
              leading: Text(log.moodEmoji, style: const TextStyle(fontSize: 24)),
              title: Text(DateHelpers.formatDate(log.date), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('😴 ${log.sleepHours}h  💧 ${log.waterGlasses} glasses'),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget child;
  const _SectionCard({required this.emoji, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 16),
      child,
    ]),
  );
}
