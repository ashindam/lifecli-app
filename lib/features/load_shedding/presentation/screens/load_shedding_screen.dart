import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/load_shedding_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

final _loadProvider = StateNotifierProvider<_LoadNotifier, List<LoadSheddingSlot>>(
  (ref) => _LoadNotifier(),
);

class _LoadNotifier extends StateNotifier<List<LoadSheddingSlot>> {
  _LoadNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.loadShedding.values.whereType<LoadSheddingSlot>().toList()
      ..sort((a, b) => a.dayOfWeek == b.dayOfWeek ? a.startTime.compareTo(b.startTime) : a.dayOfWeek.compareTo(b.dayOfWeek));
  }
  Future<void> add(LoadSheddingSlot s) async { await HiveService.loadShedding.put(s.id, s); _load(); }
  Future<void> delete(String id) async { await HiveService.loadShedding.delete(id); _load(); }
  Future<void> toggle(String id) async {
    final s = state.firstWhere((s) => s.id == id);
    await HiveService.loadShedding.put(id, s.copyWith(isEnabled: !s.isEnabled)); _load();
  }
}

class LoadSheddingScreen extends ConsumerWidget {
  const LoadSheddingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(_loadProvider);
    final now = DateTime.now();
    final isCurrentlyActive = slots.any((s) => s.isCurrentlyActive());
    final activeSlot = isCurrentlyActive ? slots.firstWhere((s) => s.isCurrentlyActive()) : null;

    // Find next slot today or upcoming
    LoadSheddingSlot? nextSlot;
    final nowMins = now.hour * 60 + now.minute;
    for (final s in slots.where((s) => s.isEnabled)) {
      final sParts = s.startTime.split(':');
      final startMins = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
      if (s.dayOfWeek == now.weekday && startMins > nowMins) {
        nextSlot = s;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Load Shedding', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: Column(children: [
        // Status banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCurrentlyActive
                  ? [const Color(0xFFDC2626), AppColors.error]
                  : [AppColors.success, const Color(0xFF059669)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Text(isCurrentlyActive ? '⚡' : '✅', style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isCurrentlyActive ? 'Power Cut Active' : 'Power Available',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              if (isCurrentlyActive && activeSlot != null)
                Text('Until ${activeSlot.endTime} • ${activeSlot.area}',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70))
              else if (nextSlot != null)
                Text('Next: ${nextSlot.startTime}–${nextSlot.endTime} today',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70))
              else
                Text('No more outages scheduled today',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            ])),
          ]),
        ),

        if (isCurrentlyActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text('Use this time for reading, handwritten notes, or offline tasks.',
                  style: GoogleFonts.inter(fontSize: 12))),
              ]),
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text('Weekly Schedule', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${slots.length} slot${slots.length == 1 ? '' : 's'}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: slots.isEmpty
              ? const EmptyState(emoji: '⚡', title: 'No schedule added', subtitle: 'Add your area\'s load shedding schedule to track outages')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final s = slots[i];
                    final isActive = s.isCurrentlyActive();
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => ref.read(_loadProvider.notifier).delete(s.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.error.withOpacity(0.05) : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isActive ? AppColors.error.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(children: [
                          Text(isActive ? '⚡' : '🌙', style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.area, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(s.timeRange, style: GoogleFonts.inter(fontSize: 13,
                              color: isActive ? AppColors.error : Colors.grey,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
                            Text(s.dayName, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                                child: Text('ACTIVE', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            Switch(
                              value: s.isEnabled,
                              onChanged: (_) => ref.read(_loadProvider.notifier).toggle(s.id),
                              activeColor: AppColors.primary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Schedule'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final areaCtrl = TextEditingController(text: 'My Area');
    int selectedDay = DateTime.now().weekday;
    TimeOfDay startTime = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0);
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add Schedule', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Area / Zone name')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: 'Day of Week'),
              items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(dayNames[i]))),
              onChanged: (v) => setSt(() => selectedDay = v ?? 1),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: startTime);
                  if (t != null) setSt(() => startTime = t);
                },
                icon: const Icon(Icons.access_time, size: 16),
                label: Text('Start: ${startTime.format(ctx)}'),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: endTime);
                  if (t != null) setSt(() => endTime = t);
                },
                icon: const Icon(Icons.access_time, size: 16),
                label: Text('End: ${endTime.format(ctx)}'),
              )),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final startStr = '${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}';
                final endStr = '${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}';
                ref.read(_loadProvider.notifier).add(LoadSheddingSlot(
                  dayOfWeek: selectedDay,
                  startTime: startStr,
                  endTime: endStr,
                  area: areaCtrl.text.trim().isEmpty ? 'My Area' : areaCtrl.text.trim(),
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
