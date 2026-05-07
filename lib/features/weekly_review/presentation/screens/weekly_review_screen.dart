import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../tasks/data/task_model.dart';
import '../../../habits/data/habit_model.dart';
import '../../../expenses/data/expense_model.dart';
import '../../../study_logger/data/study_session_model.dart';

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Gather data for this week
    final allTasks = HiveService.tasks.values.whereType<TaskModel>().toList();
    final weekTasks = allTasks.where((t) => t.dueDate != null && DateHelpers.isSameWeek(t.dueDate!, weekStart)).toList();
    final doneTasks = weekTasks.where((t) => t.status == TaskStatus.completed).toList();
    final overdueTasks = allTasks.where((t) => t.isOverdue).toList();

    final allHabits = HiveService.habits.values.whereType<HabitModel>().toList();
    final allLogs = HiveService.habitLogs.values.whereType<HabitLogModel>().toList();
    final weekLogs = allLogs.where((l) => DateHelpers.isSameWeek(l.date, weekStart)).toList();

    final allExpenses = HiveService.expenses.values.whereType<ExpenseModel>().toList();
    final weekExpenses = allExpenses.where((e) => DateHelpers.isSameWeek(e.date, weekStart)).toList();
    final weekSpendingPaisa = weekExpenses.fold(0, (sum, e) => sum + e.amountPaisa);

    final allSessions = HiveService.studySessions.values.whereType<StudySessionModel>().toList();
    final weekStudy = allSessions.where((s) => DateHelpers.isSameWeek(s.date, weekStart)).toList();
    final studyMinutes = weekStudy.fold(0, (sum, s) => sum + s.durationMinutes);

    final completionRate = weekTasks.isEmpty ? 0.0 : doneTasks.length / weekTasks.length;
    final habitRate = allHabits.isEmpty ? 0.0 : weekLogs.length / (allHabits.length * 7.0);

    return Scaffold(
      appBar: AppBar(title: Text('Weekly Review', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Week header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Text('📅', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Week Review', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${_fmt(weekStart)} – ${_fmt(weekEnd)}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(_getOverallMood(completionRate, habitRate), style: GoogleFonts.inter(fontSize: 20)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Quick stats
          _SectionHeader('📊 At a Glance'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
            children: [
              _StatCard('✅ Tasks Done', '${doneTasks.length}/${weekTasks.length}', '${(completionRate * 100).round()}%', AppColors.success, AppColors.successContainer),
              _StatCard('🔥 Habit Rate', '${weekLogs.length} logs', '${(habitRate * 100).round()}%', AppColors.primary, AppColors.primaryContainer),
              _StatCard('📚 Study Time', '${studyMinutes ~/ 60}h ${studyMinutes % 60}m', '${weekStudy.length} sessions', AppColors.accent, AppColors.warningContainer),
              _StatCard('💸 Spending', '৳${(weekSpendingPaisa / 100).toStringAsFixed(0)}', '${weekExpenses.length} transactions', AppColors.error, AppColors.errorContainer),
            ],
          ),
          const SizedBox(height: 20),

          // Task breakdown
          _SectionHeader('✅ Task Breakdown'),
          const SizedBox(height: 10),
          _ProgressRow('Completed', doneTasks.length, weekTasks.length, AppColors.success),
          const SizedBox(height: 6),
          _ProgressRow('Overdue', overdueTasks.length, weekTasks.isEmpty ? 1 : weekTasks.length, AppColors.error),
          const SizedBox(height: 20),

          // Habit performance
          _SectionHeader('🔥 Habit Performance'),
          const SizedBox(height: 10),
          if (allHabits.isEmpty)
            _EmptySection('No habits tracked yet')
          else
            ...allHabits.map((h) {
              final hLogs = weekLogs.where((l) => l.habitId == h.id).length;
              return _HabitWeekRow(habit: h, checkedDays: hLogs);
            }),
          const SizedBox(height: 20),

          // Study breakdown
          _SectionHeader('📚 Study Sessions'),
          const SizedBox(height: 10),
          if (weekStudy.isEmpty)
            _EmptySection('No study sessions this week')
          else ...[
            ...weekStudy.take(5).map((s) => ListTile(
              dense: true,
              leading: Text(_subjectEmoji(s.subject), style: const TextStyle(fontSize: 18)),
              title: Text(s.subject.isNotEmpty ? s.subject : 'General Study', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(DateHelpers.relativeDate(s.date), style: GoogleFonts.inter(fontSize: 11)),
              trailing: Text('${s.durationMinutes ~/ 60}h ${s.durationMinutes % 60}m', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              contentPadding: EdgeInsets.zero,
            )),
          ],
          const SizedBox(height: 20),

          // Top spending categories
          _SectionHeader('💸 Top Expenses'),
          const SizedBox(height: 10),
          if (weekExpenses.isEmpty)
            _EmptySection('No expenses this week')
          else ...[
            ..._topCategories(weekExpenses).entries.take(4).map((e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Text(e.key.split(' ').first, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.key.split(' ').skip(1).join(' '), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600))),
                  Text('৳${(e.value / 100).toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Reflection prompt
          _SectionHeader('🧠 Reflection'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...[
                'What went well this week?',
                'What could you improve next week?',
                'What\'s your top priority for next week?',
              ].map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text('Tap to add note...', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 20),

          // Next week intentions
          _SectionHeader('🎯 Next Week\'s Focus'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(children: [
              ...[
                ('📌', 'Top 3 priorities set', completionRate > 0.5),
                ('🔥', 'Habits reviewed', weekLogs.isNotEmpty),
                ('📚', 'Study goals updated', studyMinutes > 0),
                ('💸', 'Budget checked', weekSpendingPaisa > 0),
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text(item.$1, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.$2, style: GoogleFonts.inter(fontSize: 13))),
                  Icon(item.$3 ? Icons.check_circle : Icons.circle_outlined,
                    color: item.$3 ? AppColors.success : Colors.grey, size: 18),
                ]),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}';
  String _getOverallMood(double taskRate, double habitRate) {
    final avg = (taskRate + habitRate) / 2;
    if (avg >= 0.8) return '🌟 Excellent week!';
    if (avg >= 0.6) return '👍 Good progress!';
    if (avg >= 0.4) return '📈 Room to grow';
    return '💪 Keep pushing!';
  }

  String _subjectEmoji(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('math')) return '📐';
    if (lower.contains('phys')) return '⚡';
    if (lower.contains('chem')) return '🧪';
    if (lower.contains('cs') || lower.contains('code')) return '💻';
    return '📚';
  }

  Map<String, int> _topCategories(List<ExpenseModel> expenses) {
    final map = <String, int>{};
    for (final e in expenses) { map[e.category] = (map[e.category] ?? 0) + e.amountPaisa; }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}

Widget _SectionHeader(String title) => Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700));

Widget _EmptySection(String msg) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
);

class _StatCard extends StatelessWidget {
  final String title, value, sub;
  final Color color, bg;
  const _StatCard(this.title, this.value, this.sub, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(sub, style: GoogleFonts.inter(fontSize: 11, color: color.withOpacity(0.7))),
    ]),
  );
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _ProgressRow(this.label, this.count, this.total, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 13))),
    Expanded(child: LinearProgressIndicator(
      value: total > 0 ? count / total : 0,
      minHeight: 8, backgroundColor: const Color(0xFFE2E8F0),
      valueColor: AlwaysStoppedAnimation(color),
      borderRadius: BorderRadius.circular(4),
    )),
    const SizedBox(width: 10),
    Text('$count/$total', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}

class _HabitWeekRow extends StatelessWidget {
  final HabitModel habit;
  final int checkedDays;
  const _HabitWeekRow({required this.habit, required this.checkedDays});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      const Text('💪', style: TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(habit.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(children: List.generate(7, (i) => Container(
          width: 20, height: 20, margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: i < checkedDays ? AppColors.success : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        ))),
      ])),
      Text('$checkedDays/7', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: checkedDays >= 5 ? AppColors.success : Colors.grey)),
    ]),
  );
}

