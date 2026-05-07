import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/tuition_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/bdt_input_field.dart';
import '../../../../core/widgets/empty_state.dart';

final _tuitionProvider = StateNotifierProvider<_TuitionNotifier, List<TuitionStudentModel>>(
  (ref) => _TuitionNotifier(),
);

class _TuitionNotifier extends StateNotifier<List<TuitionStudentModel>> {
  _TuitionNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.tuitionStudents.values.whereType<TuitionStudentModel>().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
  Future<void> add(TuitionStudentModel s) async { await HiveService.tuitionStudents.put(s.id, s); _load(); }
  Future<void> update(TuitionStudentModel s) async { await HiveService.tuitionStudents.put(s.id, s); _load(); }
  Future<void> delete(String id) async { await HiveService.tuitionStudents.delete(id); _load(); }
  Future<void> markSession(String id) async {
    final s = state.firstWhere((s) => s.id == id);
    if (s.completedSessions >= s.sessionsPerMonth) return;
    await update(s.copyWith(completedSessions: s.completedSessions + 1));
  }
  Future<void> resetMonth(String id) async {
    final s = state.firstWhere((s) => s.id == id);
    await update(s.copyWith(completedSessions: 0));
  }
}

class TuitionScreen extends ConsumerWidget {
  const TuitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(_tuitionProvider);
    final totalExpected = students.fold(0, (s, st) => s + st.monthlySalaryPaisa);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tuition Manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {})],
      ),
      body: students.isEmpty
          ? const EmptyState(emoji: '👨‍🏫', title: 'No students yet', subtitle: 'Add your private tuition students')
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Monthly Income', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                      Text(CurrencyFormatter.format(totalExpected),
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('${students.length} student${students.length == 1 ? '' : 's'}', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                    ])),
                    const Text('💼', style: TextStyle(fontSize: 48)),
                  ]),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _StudentCard(
                      student: students[i],
                      onMarkSession: () => ref.read(_tuitionProvider.notifier).markSession(students[i].id),
                      onReset: () => ref.read(_tuitionProvider.notifier).resetMonth(students[i].id),
                      onDelete: () => ref.read(_tuitionProvider.notifier).delete(students[i].id),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Student'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final sessionsCtrl = TextEditingController(text: '8');
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Student', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
          const SizedBox(height: 12),
          TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
          const SizedBox(height: 12),
          BdtInputField(controller: salaryCtrl, label: 'Monthly Salary'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: sessionsCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sessions/month'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'))),
          ]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final salary = double.tryParse(salaryCtrl.text.replaceAll(',', '')) ?? 0;
              ref.read(_tuitionProvider.notifier).add(TuitionStudentModel(
                name: nameCtrl.text.trim(), subject: subjectCtrl.text.trim(),
                monthlySalaryPaisa: (salary * 100).round(),
                sessionsPerMonth: int.tryParse(sessionsCtrl.text) ?? 8,
                contactNumber: phoneCtrl.text.trim(),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Add Student'),
          )),
        ]),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final TuitionStudentModel student;
  final VoidCallback onMarkSession;
  final VoidCallback onReset;
  final VoidCallback onDelete;
  const _StudentCard({required this.student, required this.onMarkSession, required this.onReset, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final progress = student.sessionsPerMonth > 0 ? student.completedSessions / student.sessionsPerMonth : 0.0;
    final isDone = student.completedSessions >= student.sessionsPerMonth;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: Center(child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(student.subject, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          ])),
          Text(CurrencyFormatter.format(student.monthlySalaryPaisa),
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Text('${student.completedSessions}/${student.sessionsPerMonth} sessions',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (isDone) const Text('✅ Complete', style: TextStyle(color: AppColors.success, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 6,
          backgroundColor: AppColors.primaryContainer,
          valueColor: AlwaysStoppedAnimation(isDone ? AppColors.success : AppColors.primary)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: isDone ? null : onMarkSession,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Mark Session'),
          )),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.refresh, size: 18), tooltip: 'Reset month', onPressed: onReset),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: onDelete),
        ]),
      ]),
    );
  }
}
