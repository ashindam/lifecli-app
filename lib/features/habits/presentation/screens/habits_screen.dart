import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/habit_model.dart';
import '../providers/habits_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Habits', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
        ],
      ),
      body: state.habits.isEmpty
          ? const EmptyState(
              emoji: '💪',
              title: 'No habits yet',
              subtitle: 'Build positive habits. Start with just one!',
              actionLabel: 'Add Habit',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _StreakSummaryCard(state: state),
                const SizedBox(height: 20),
                Text('Habit Leaderboard',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...() {
                  final sorted = state.habits.toList()..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
                  return sorted.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HabitCard(
                      habit: e.value,
                      rank: e.key + 1,
                      isCheckedIn: state.isCheckedInToday(e.value.id),
                      onCheckIn: () => notifier.checkIn(e.value.id, DateTime.now()),
                      onUndo: () => notifier.undoCheckIn(e.value.id),
                      onDelete: () => notifier.deleteHabit(e.value.id),
                    ),
                  )).toList();
                }(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String category = 'Health';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Habit', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, autofocus: true,
                decoration: const InputDecoration(labelText: 'Habit name', hintText: 'e.g. Morning run')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Health', 'Study', 'Fitness', 'Mindfulness', 'Social', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSt(() => category = v ?? 'Health'),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    ref.read(habitsProvider.notifier).addHabit(
                      HabitModel(name: nameCtrl.text.trim(), category: category));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakSummaryCard extends StatelessWidget {
  final HabitsState state;
  const _StreakSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final checkedToday = state.habits.where((h) => state.isCheckedInToday(h.id)).length;
    final total = state.habits.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Today\'s Progress', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('$checkedToday / $total habits done',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: total > 0 ? checkedToday / total : 0,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Text(total > 0 ? '${(checkedToday / total * 100).round()}%' : '0%',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final int rank;
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onUndo;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit, required this.rank, required this.isCheckedIn,
    required this.onCheckIn, required this.onUndo, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isCheckedIn ? AppColors.successContainer : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCheckedIn ? AppColors.success.withOpacity(0.4) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: rank <= 3 ? [Colors.amber, Colors.grey[400]!, const Color(0xFFCD7F32)][rank - 1] : AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('$rank',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                  color: rank <= 3 ? Colors.white : AppColors.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(habit.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(children: [
                  Text(habit.category, style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(width: 8),
                  Text('🔥 ${habit.currentStreak} day streak',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                  if (habit.longestStreak > 0) ...[
                    const SizedBox(width: 8),
                    Text('Best: ${habit.longestStreak}',
                      style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ]),
              ]),
            ),
            GestureDetector(
              onTap: isCheckedIn ? onUndo : onCheckIn,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isCheckedIn ? AppColors.success : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCheckedIn ? Icons.check : Icons.add,
                  color: isCheckedIn ? Colors.white : AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
