import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/grade_models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/grade_scale.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

final _semesterProvider = StateNotifierProvider<_SemesterNotifier, List<SemesterModel>>(
  (ref) => _SemesterNotifier(),
);

class _SemesterNotifier extends StateNotifier<List<SemesterModel>> {
  _SemesterNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.semesters.values.whereType<SemesterModel>().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
  Future<void> addSemester(String name) async {
    final s = SemesterModel(name: name);
    await HiveService.semesters.put(s.id, s); _load();
  }
  Future<void> deleteSemester(String id) async { await HiveService.semesters.delete(id); _load(); }
  Future<void> addCourse(String semId, String courseName, int credits, double obtained, double total) async {
    final sem = state.firstWhere((s) => s.id == semId);
    final course = GradeCourseModel(
      courseName: courseName, creditHours: credits, semesterId: semId,
      components: [GradeComponent(name: 'Total', weightagePercent: 100, marksObtained: obtained, totalMarks: total)],
    );
    await HiveService.semesters.put(semId, sem.copyWith(courses: [...sem.courses, course]));
    _load();
  }
  Future<void> deleteCourse(String semId, String courseId) async {
    final sem = state.firstWhere((s) => s.id == semId);
    await HiveService.semesters.put(semId, sem.copyWith(courses: sem.courses.where((c) => c.id != courseId).toList()));
    _load();
  }
}

double _coursePercentage(GradeCourseModel c) {
  if (c.components.isEmpty) return 0;
  double earned = 0, total = 0;
  for (final comp in c.components) {
    if (comp.marksObtained != null) {
      earned += (comp.marksObtained! / comp.totalMarks) * comp.weightagePercent;
      total += comp.weightagePercent;
    }
  }
  return total > 0 ? earned / total * 100 : 0;
}

class GradeSimulatorScreen extends ConsumerWidget {
  const GradeSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(_semesterProvider);

    double weightedSum = 0; int totalCredits = 0;
    for (final sem in semesters) {
      for (final c in sem.courses) {
        final pct = _coursePercentage(c);
        if (pct > 0) {
          final grade = GradeScale.getLetterGrade(pct);
          final gp = GradeScale.gradePoints[grade] ?? 0.0;
          weightedSum += gp * c.creditHours; totalCredits += c.creditHours;
        }
      }
    }
    final cgpa = totalCredits > 0 ? weightedSum / totalCredits : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('Grade Simulator', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: semesters.isEmpty
          ? const EmptyState(emoji: '🎓', title: 'No semesters yet', subtitle: 'Add semesters and courses to simulate your GPA')
          : Column(children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cumulative GPA', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    Text(cgpa.toStringAsFixed(2), style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('out of 4.00  •  $totalCredits credits', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                  ])),
                  Column(children: [
                    Text(_gpToLetter(cgpa), style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('CGPA Grade', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                  ]),
                ]),
              ),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: semesters.length,
                itemBuilder: (ctx, i) => _SemesterCard(semester: semesters[i], ref: ref),
              )),
            ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSemesterSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Semester'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  String _gpToLetter(double cgpa) {
    if (cgpa >= 3.75) return 'A+';
    if (cgpa >= 3.5) return 'A';
    if (cgpa >= 3.25) return 'A-';
    if (cgpa >= 3.0) return 'B+';
    if (cgpa >= 2.75) return 'B';
    if (cgpa >= 2.5) return 'B-';
    if (cgpa >= 2.25) return 'C+';
    if (cgpa >= 2.0) return 'C';
    if (cgpa >= 1.0) return 'D';
    return cgpa == 0 ? '—' : 'F';
  }

  void _addSemesterSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Semester', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Semester Name (e.g. 1st Sem, Spring 2024)')),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              ref.read(_semesterProvider.notifier).addSemester(nameCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          )),
        ]),
      ),
    );
  }
}

class _SemesterCard extends StatefulWidget {
  final SemesterModel semester;
  final WidgetRef ref;
  const _SemesterCard({required this.semester, required this.ref});
  @override State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _expanded = true;

  double get _sgpa {
    int credits = 0; double weighted = 0;
    for (final c in widget.semester.courses) {
      final pct = _coursePercentage(c);
      if (pct > 0) {
        final grade = GradeScale.getLetterGrade(pct);
        final gp = GradeScale.gradePoints[grade] ?? 0.0;
        weighted += gp * c.creditHours; credits += c.creditHours;
      }
    }
    return credits > 0 ? weighted / credits : 0;
  }

  @override
  Widget build(BuildContext context) {
    final sgpa = _sgpa;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.semester.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('SGPA: ${sgpa.toStringAsFixed(2)} • ${widget.semester.courses.length} courses',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ])),
              PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'add', child: Text('Add Course')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete Semester')),
                ],
                onSelected: (v) {
                  if (v == 'add') _addCourseSheet();
                  if (v == 'delete') widget.ref.read(_semesterProvider.notifier).deleteSemester(widget.semester.id);
                },
              ),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ]),
          ),
        ),
        if (_expanded) ...[
          if (widget.semester.courses.isNotEmpty) ...[
            const Divider(height: 1),
            ...widget.semester.courses.map((c) {
              final pct = _coursePercentage(c);
              final grade = pct > 0 ? GradeScale.getLetterGrade(pct) : '—';
              final gp = GradeScale.gradePoints[grade] ?? 0.0;
              return ListTile(
                dense: true,
                title: Text(c.courseName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('${c.creditHours} credits • ${pct.toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(grade, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _gradeColor(grade))),
                    Text('GP ${gp.toStringAsFixed(1)}', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  ]),
                  PopupMenuButton(
                    iconSize: 18,
                    itemBuilder: (_) => [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                    onSelected: (v) { if (v == 'delete') widget.ref.read(_semesterProvider.notifier).deleteCourse(widget.semester.id, c.id); },
                  ),
                ]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }),
          ],
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: TextButton.icon(
              onPressed: _addCourseSheet,
              icon: const Icon(Icons.add, size: 16), label: const Text('Add Course'),
            ),
          ),
        ],
      ]),
    );
  }

  Color _gradeColor(String grade) {
    if (grade == 'A+' || grade == 'A') return AppColors.success;
    if (grade == 'A-' || grade == 'B+') return AppColors.primary;
    if (grade == 'B' || grade == 'B-') return AppColors.accent;
    if (grade == 'C+' || grade == 'C') return AppColors.warning;
    return AppColors.error;
  }

  void _addCourseSheet() {
    final nameCtrl = TextEditingController();
    final creditCtrl = TextEditingController(text: '3');
    final obtainedCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final pct = double.tryParse(obtainedCtrl.text) != null && double.tryParse(totalCtrl.text) != null
              ? (double.parse(obtainedCtrl.text) / double.parse(totalCtrl.text)) * 100
              : 0.0;
          final grade = pct > 0 ? GradeScale.getLetterGrade(pct) : '—';
          final gp = GradeScale.gradePoints[grade] ?? 0.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Course to ${widget.semester.name}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Course Name')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: creditCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credits'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, onChanged: (_) => setSt((){}), decoration: const InputDecoration(labelText: 'Total Marks'))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: obtainedCtrl, keyboardType: TextInputType.number, onChanged: (_) => setSt((){}), decoration: const InputDecoration(labelText: 'Obtained Marks')),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [Text(grade, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)), const Text('Grade')]),
                  Column(children: [Text(gp.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)), const Text('GP')]),
                  Column(children: [Text('${pct.toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)), const Text('Score')]),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  widget.ref.read(_semesterProvider.notifier).addCourse(
                    widget.semester.id,
                    nameCtrl.text.trim(),
                    int.tryParse(creditCtrl.text) ?? 3,
                    double.tryParse(obtainedCtrl.text) ?? 0,
                    double.tryParse(totalCtrl.text) ?? 100,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Add Course'),
              )),
            ]),
          );
        },
      ),
    );
  }
}
