import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/study_session_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

final _studyProvider = StateNotifierProvider<_StudyNotifier, List<StudySessionModel>>(
  (ref) => _StudyNotifier(),
);

class _StudyNotifier extends StateNotifier<List<StudySessionModel>> {
  _StudyNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.studySessions.values.whereType<StudySessionModel>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  Future<void> add(StudySessionModel s) async { await HiveService.studySessions.put(s.id, s); _load(); }
  Future<void> delete(String id) async { await HiveService.studySessions.delete(id); _load(); }
}

class StudyLoggerScreen extends ConsumerStatefulWidget {
  const StudyLoggerScreen({super.key});
  @override ConsumerState<StudyLoggerScreen> createState() => _StudyLoggerScreenState();
}

class _StudyLoggerScreenState extends ConsumerState<StudyLoggerScreen> {
  bool _isRunning = false;
  DateTime? _startTime;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  dynamic _timer;

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      if (_startTime != null) _showSaveSheet();
      setState(() { _isRunning = false; });
    } else {
      _startTime = DateTime.now();
      _elapsedSeconds = 0;
      _timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
      setState(() { _isRunning = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(_studyProvider);

    // Weekly stats
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekSessions = sessions.where((s) => s.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
    final weekMinutes = weekSessions.fold(0, (sum, s) => sum + s.durationMinutes);

    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    final timerText = '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';

    return Scaffold(
      appBar: AppBar(title: Text('Study Logger', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: Column(children: [
        // Timer hero
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isRunning ? [AppColors.success, const Color(0xFF059669)] : [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: [
            Text('📚', style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(timerText, style: GoogleFonts.inter(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(_isRunning ? 'Study session active...' : 'Tap to start tracking', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: FilledButton(
                onPressed: _startStop,
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _isRunning ? AppColors.error : AppColors.primary),
                child: Text(_isRunning ? '⏹ Stop' : '▶ Start', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
        // Weekly summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _StatCard('This Week', '${weekMinutes ~/ 60}h ${weekMinutes % 60}m', Icons.calendar_today),
            const SizedBox(width: 10),
            _StatCard('Sessions', weekSessions.length.toString(), Icons.book_outlined),
            const SizedBox(width: 10),
            _StatCard('Daily Avg', weekMinutes > 0 ? '${(weekMinutes / 7).round()}m' : '0m', Icons.show_chart),
          ]),
        ),
        const SizedBox(height: 12),
        const Divider(indent: 16, endIndent: 16),
        Expanded(
          child: sessions.isEmpty
              ? const EmptyState(emoji: '📖', title: 'No sessions yet', subtitle: 'Start the timer to log your study sessions')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final s = sessions[i];
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) => ref.read(_studyProvider.notifier).delete(s.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(children: [
                          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(_subjectEmoji(s.subject), style: const TextStyle(fontSize: 22)))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.subject.isNotEmpty ? s.subject : 'General Study', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(DateHelpers.relativeDate(s.date), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            if (s.notes.isNotEmpty) Text(s.notes, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${s.durationMinutes ~/ 60}h ${s.durationMinutes % 60}m',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            Text('${s.durationMinutes} min', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManualSheet(),
        child: const Icon(Icons.edit_outlined),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        tooltip: 'Log manually',
      ),
    );
  }

  String _subjectEmoji(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math') || s.contains('calc')) return '📐';
    if (s.contains('physics')) return '⚡';
    if (s.contains('chem')) return '🧪';
    if (s.contains('bio')) return '🧬';
    if (s.contains('cs') || s.contains('program') || s.contains('code')) return '💻';
    if (s.contains('english') || s.contains('bangla')) return '📝';
    return '📚';
  }

  void _showSaveSheet() {
    final subjectCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final duration = _elapsedSeconds ~/ 60;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Save Study Session', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Duration: ${duration ~/ 60}h ${duration % 60}m', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject (optional)')),
          const SizedBox(height: 12),
          TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); setState(() { _elapsedSeconds = 0; _startTime = null; }); }, child: const Text('Discard'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              onPressed: () {
                if (duration > 0) {
                  ref.read(_studyProvider.notifier).add(StudySessionModel(
                    date: _startTime ?? DateTime.now().subtract(Duration(seconds: _elapsedSeconds)),
                    durationMinutes: duration,
                    subject: subjectCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  ));
                }
                Navigator.pop(ctx);
                setState(() { _elapsedSeconds = 0; _startTime = null; });
              },
              child: const Text('Save'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _showManualSheet() {
    final subjectCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int hours = 1, minutes = 0;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Log Session Manually', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(children: [
                Text('Hours', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(onPressed: () { if (hours > 0) setSt(() => hours--); }, icon: const Icon(Icons.remove)),
                  Text('$hours', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => setSt(() => hours++), icon: const Icon(Icons.add)),
                ]),
              ])),
              Expanded(child: Column(children: [
                Text('Minutes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(onPressed: () { if (minutes >= 15) setSt(() => minutes -= 15); }, icon: const Icon(Icons.remove)),
                  Text('$minutes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () { if (minutes < 45) setSt(() => minutes += 15); }, icon: const Icon(Icons.add)),
                ]),
              ])),
            ]),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final totalMin = hours * 60 + minutes;
                if (totalMin <= 0) return;
                ref.read(_studyProvider.notifier).add(StudySessionModel(
                  date: DateTime.now().subtract(Duration(minutes: totalMin)),
                  durationMinutes: totalMin,
                  subject: subjectCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )),
          ]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _StatCard(this.title, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
      Text(title, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
    ]),
  ));
}
