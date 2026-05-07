import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/grade_models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/university_data.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final _semesterProvider =
    StateNotifierProvider<_SemesterNotifier, List<SemesterModel>>(
  (ref) => _SemesterNotifier(),
);

final _gradingSystemProvider = FutureProvider<GradingSystem>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final savedUniversity = prefs.getString('university') ?? '';
  final match = bangladeshiUniversities.where(
    (u) => u.name == savedUniversity || u.shortName == savedUniversity,
  );
  return match.isNotEmpty ? match.first.gradingSystem : publicUniversityGrading;
});

// ─── Notifier ──────────────────────────────────────────────────────────────

class _SemesterNotifier extends StateNotifier<List<SemesterModel>> {
  _SemesterNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.semesters.values.whereType<SemesterModel>().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addSemester(String name) async {
    final s = SemesterModel(name: name);
    await HiveService.semesters.put(s.id, s);
    _load();
  }

  Future<void> deleteSemester(String id) async {
    await HiveService.semesters.delete(id);
    _load();
  }

  Future<void> addCourse(String semId, String courseName, int credits,
      double obtained, double total) async {
    final sem = state.firstWhere((s) => s.id == semId);
    final course = GradeCourseModel(
      courseName: courseName,
      creditHours: credits,
      semesterId: semId,
      components: [
        GradeComponent(
            name: 'Total',
            weightagePercent: 100,
            marksObtained: obtained,
            totalMarks: total)
      ],
    );
    await HiveService.semesters
        .put(semId, sem.copyWith(courses: [...sem.courses, course]));
    _load();
  }

  Future<void> deleteCourse(String semId, String courseId) async {
    final sem = state.firstWhere((s) => s.id == semId);
    await HiveService.semesters.put(
        semId,
        sem.copyWith(
            courses:
                sem.courses.where((c) => c.id != courseId).toList()));
    _load();
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

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

double _calcSGPA(List<GradeCourseModel> courses, GradingSystem gs) {
  int credits = 0;
  double weighted = 0;
  for (final c in courses) {
    final pct = _coursePercentage(c);
    if (pct > 0) {
      weighted += gs.percentToGPA(pct) * c.creditHours;
      credits += c.creditHours;
    }
  }
  return credits > 0 ? weighted / credits : 0;
}

Color _gradeColor(String grade) {
  if (grade.startsWith('A')) return AppColors.success;
  if (grade.startsWith('B')) return AppColors.primary;
  if (grade.startsWith('C')) return AppColors.warning;
  if (grade == 'Pass' || grade == 'Credit' || grade == 'Distinction') {
    return AppColors.success;
  }
  return AppColors.error;
}

// ─── Main Screen ───────────────────────────────────────────────────────────

class GradeSimulatorScreen extends ConsumerWidget {
  const GradeSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(_semesterProvider);
    final gradingAsync = ref.watch(_gradingSystemProvider);

    return gradingAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (gs) {
        // CGPA across all semesters
        double weightedSum = 0;
        int totalCredits = 0;
        for (final sem in semesters) {
          for (final c in sem.courses) {
            final pct = _coursePercentage(c);
            if (pct > 0) {
              weightedSum += gs.percentToGPA(pct) * c.creditHours;
              totalCredits += c.creditHours;
            }
          }
        }
        final cgpa =
            totalCredits > 0 ? weightedSum / totalCredits : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            title: Text('Grade Calculator',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          body: semesters.isEmpty
              ? EmptyState(
                  emoji: '🎓',
                  title: 'No semesters yet',
                  subtitle:
                      'Tap + to add your first semester and start tracking grades',
                  actionLabel: 'Add Semester',
                  onAction: () => _addSemesterSheet(context, ref),
                )
              : Column(
                  children: [
                    // ── CGPA card ────────────────────────────────────────
                    _CgpaCard(
                        cgpa: cgpa,
                        totalCredits: totalCredits,
                        semesterCount: semesters.length,
                        gradingSystem: gs),
                    // ── Grading scale chip ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_outlined,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(gs.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Semester list ─────────────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        itemCount: semesters.length,
                        itemBuilder: (ctx, i) => _SemesterCard(
                          semester: semesters[i],
                          ref: ref,
                          gradingSystem: gs,
                        ),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addSemesterSheet(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Semester'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        );
      },
    );
  }

  void _addSemesterSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Semester',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. 1st Semester, Spring 2024',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ref
                    .read(_semesterProvider.notifier)
                    .addSemester(nameCtrl.text.trim());
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Semester',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── CGPA Card ─────────────────────────────────────────────────────────────

class _CgpaCard extends StatelessWidget {
  const _CgpaCard({
    required this.cgpa,
    required this.totalCredits,
    required this.semesterCount,
    required this.gradingSystem,
  });

  final double cgpa;
  final int totalCredits;
  final int semesterCount;
  final GradingSystem gradingSystem;

  String _cgpaToLetter() {
    if (cgpa == 0) return '—';
    // Use the highest grade threshold from the grading system
    return gradingSystem.percentToGrade(
        _gpToPercent(cgpa, gradingSystem));
  }

  double _gpToPercent(double gp, GradingSystem gs) {
    // Find approximate percent from GP by reversing the scale
    for (final g in gs.grades) {
      if (gp >= g.points - 0.01) return g.minPercent.toDouble();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CGPA (Cumulative)',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  cgpa > 0 ? cgpa.toStringAsFixed(2) : '—',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'out of 4.00  •  $totalCredits credits  •  $semesterCount semesters',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                _cgpaToLetter(),
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text('Grade',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Semester Card ─────────────────────────────────────────────────────────

class _SemesterCard extends StatefulWidget {
  const _SemesterCard({
    required this.semester,
    required this.ref,
    required this.gradingSystem,
  });

  final SemesterModel semester;
  final WidgetRef ref;
  final GradingSystem gradingSystem;

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final sgpa = _calcSGPA(widget.semester.courses, widget.gradingSystem);
    final totalCredits =
        widget.semester.courses.fold(0, (s, c) => s + c.creditHours);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.semester.name,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(
                          'SGPA: ${sgpa > 0 ? sgpa.toStringAsFixed(2) : "—"}  •  $totalCredits credits  •  ${widget.semester.courses.length} courses',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  // SGPA pill
                  if (sgpa > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(sgpa.toStringAsFixed(2),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: Color(0xFF94A3B8)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'add', child: Text('Add Course')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Semester',
                              style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) {
                      if (v == 'add') _addCourseSheet();
                      if (v == 'delete') {
                        widget.ref
                            .read(_semesterProvider.notifier)
                            .deleteSemester(widget.semester.id);
                      }
                    },
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),

          // Course list
          if (_expanded) ...[
            if (widget.semester.courses.isNotEmpty) ...[
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ...widget.semester.courses.map((c) {
                final pct = _coursePercentage(c);
                final grade = pct > 0
                    ? widget.gradingSystem.percentToGrade(pct)
                    : '—';
                final gp = pct > 0
                    ? widget.gradingSystem.percentToGPA(pct)
                    : 0.0;
                return _CourseRow(
                  course: c,
                  grade: grade,
                  gp: gp,
                  percentage: pct,
                  onDelete: () => widget.ref
                      .read(_semesterProvider.notifier)
                      .deleteCourse(widget.semester.id, c.id),
                );
              }),
            ],
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            TextButton.icon(
              onPressed: _addCourseSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Course',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addCourseSheet() {
    final nameCtrl = TextEditingController();
    final creditCtrl = TextEditingController(text: '3');
    final obtainedCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final obtained = double.tryParse(obtainedCtrl.text);
          final total = double.tryParse(totalCtrl.text);
          final pct = (obtained != null && total != null && total > 0)
              ? (obtained / total) * 100
              : 0.0;
          final grade = pct > 0
              ? widget.gradingSystem.percentToGrade(pct)
              : '—';
          final gp =
              pct > 0 ? widget.gradingSystem.percentToGPA(pct) : 0.0;
          final color = pct > 0 ? _gradeColor(grade) : Colors.grey;

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Course',
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(widget.semester.name,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 20),

                  // Course name
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'e.g. Data Structures',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Credits + Total marks
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: creditCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Credit Hours',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: totalCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setSt(() {}),
                        decoration: InputDecoration(
                          labelText: 'Total Marks',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  // Obtained marks
                  TextField(
                    controller: obtainedCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setSt(() {}),
                    decoration: InputDecoration(
                      labelText: 'Marks Obtained',
                      hintText:
                          'out of ${totalCtrl.text.isEmpty ? "100" : totalCtrl.text}',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Live grade preview
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: pct > 0
                          ? color.withOpacity(0.08)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: pct > 0
                              ? color.withOpacity(0.3)
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _PreviewStat(
                          label: 'Grade',
                          value: grade,
                          color: color,
                          large: true,
                        ),
                        _PreviewStat(
                          label: 'Grade Point',
                          value: pct > 0 ? gp.toStringAsFixed(2) : '—',
                          color: color,
                        ),
                        _PreviewStat(
                          label: 'Percentage',
                          value:
                              pct > 0 ? '${pct.toStringAsFixed(1)}%' : '—',
                          color: color,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        widget.ref
                            .read(_semesterProvider.notifier)
                            .addCourse(
                              widget.semester.id,
                              nameCtrl.text.trim(),
                              int.tryParse(creditCtrl.text) ?? 3,
                              double.tryParse(obtainedCtrl.text) ?? 0,
                              double.tryParse(totalCtrl.text) ?? 100,
                            );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Add Course',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Course Row ────────────────────────────────────────────────────────────

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.grade,
    required this.gp,
    required this.percentage,
    required this.onDelete,
  });

  final GradeCourseModel course;
  final String grade;
  final double gp;
  final double percentage;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = percentage > 0 ? _gradeColor(grade) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Grade badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(grade,
                  style: GoogleFonts.inter(
                    fontSize: grade.length > 2 ? 9 : 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.courseName,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A))),
                Text(
                  '${course.creditHours} credits  •  ${percentage > 0 ? "${percentage.toStringAsFixed(1)}%" : "—"}  •  GP: ${gp.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: Color(0xFFCBD5E1)),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Preview Stat ──────────────────────────────────────────────────────────

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: large ? 28 : 20,
            fontWeight: FontWeight.w800,
            color: value == '—' ? Colors.grey : color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }
}
