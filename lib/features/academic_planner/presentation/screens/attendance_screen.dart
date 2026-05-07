import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../data/academic_models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

// Groups attendance records by courseName for display
class _CourseAttendance {
  final String courseName;
  final double minPercent;
  int present;
  int total;
  _CourseAttendance({required this.courseName, required this.minPercent, this.present = 0, this.total = 0});
  double get percent => total > 0 ? present / total : 0;
  int get canMiss {
    if (total == 0) return 99;
    final needed = (minPercent / 100 * (total + 1)).ceil();
    return present - needed;
  }
}

final _attendanceProvider = StateNotifierProvider<_AttNotifier, List<AttendanceRecord>>(
  (ref) => _AttNotifier(),
);

class _AttNotifier extends StateNotifier<List<AttendanceRecord>> {
  _AttNotifier() : super([]) { _load(); }

  void _load() {
    state = HiveService.attendance.values.whereType<AttendanceRecord>().toList();
  }

  Future<void> addRecord(AttendanceRecord record) async {
    await HiveService.attendance.put(record.id, record);
    _load();
  }

  Future<void> mark(String courseName, bool isPresent, double minPercent) async {
    final today = DateHelpers.toIso(DateTime.now());
    final alreadyMarked = state.any(
      (r) => r.courseName == courseName && DateHelpers.toIso(r.date) == today,
    );
    if (alreadyMarked) return;
    final record = AttendanceRecord(
      courseName: courseName,
      date: DateTime.now(),
      isPresent: isPresent,
      minimumPercent: minPercent,
    );
    await HiveService.attendance.put(record.id, record);
    _load();
  }
}

// Build course-level stats from flat AttendanceRecord list
List<_CourseAttendance> _groupByCourse(List<AttendanceRecord> records) {
  final map = <String, _CourseAttendance>{};
  for (final r in records) {
    if (!map.containsKey(r.courseName)) {
      map[r.courseName] = _CourseAttendance(
        courseName: r.courseName,
        minPercent: r.minimumPercent,
      );
    }
    map[r.courseName]!.total++;
    if (r.isPresent) map[r.courseName]!.present++;
  }
  return map.values.toList();
}

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(_attendanceProvider);
    final courses = _groupByCourse(records);

    return Scaffold(
      appBar: AppBar(title: Text('Attendance', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: courses.isEmpty
          ? const EmptyState(emoji: '📊', title: 'No courses', subtitle: 'Add courses to track attendance', actionLabel: 'Add Course')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _CourseCard(
                course: courses[i],
                onMark: (present) => ref.read(_attendanceProvider.notifier)
                    .mark(courses[i].courseName, present, courses[i].minPercent),
                records: records,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Course'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddCourseSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    double minPercent = 75;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add Course', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Course Name'), autofocus: true),
            const SizedBox(height: 14),
            Text('Minimum Required: ${minPercent.round()}%', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Slider(value: minPercent, min: 50, max: 100, divisions: 10, label: '${minPercent.round()}%',
              onChanged: (v) => setSt(() => minPercent = v), activeColor: AppColors.primary),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                // Add a placeholder record to register the course
                ref.read(_attendanceProvider.notifier).addRecord(
                  AttendanceRecord(
                    courseName: nameCtrl.text.trim(),
                    date: DateTime.now(),
                    isPresent: true,
                    minimumPercent: minPercent,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )),
          ]),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseAttendance course;
  final ValueChanged<bool> onMark;
  final List<AttendanceRecord> records;
  const _CourseCard({required this.course, required this.onMark, required this.records});

  @override
  Widget build(BuildContext context) {
    final percent = course.percent;
    final isSafe = percent >= course.minPercent / 100;
    final canMiss = course.canMiss;
    final danger = canMiss <= 2 && canMiss >= 0;

    final today = DateHelpers.toIso(DateTime.now());
    final alreadyMarked = records.any(
      (r) => r.courseName == course.courseName && DateHelpers.toIso(r.date) == today,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSafe ? const Color(0xFFE2E8F0) : AppColors.error.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(course.courseName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700))),
          CircularPercentIndicator(
            radius: 28, lineWidth: 5,
            percent: percent.clamp(0, 1),
            center: Text('${(percent * 100).round()}%', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700)),
            progressColor: isSafe ? AppColors.success : AppColors.error,
            backgroundColor: AppColors.primaryContainer,
          ),
        ]),
        const SizedBox(height: 8),
        Text('${course.present}/${course.total} classes · Min ${course.minPercent.round()}%',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
        if (canMiss >= 0)
          Text(
            danger ? '⚠️ Can miss only $canMiss more class${canMiss == 1 ? '' : 'es'}!' : 'Can miss $canMiss more classes safely',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: danger ? AppColors.error : AppColors.success),
          )
        else
          Text('❌ Already below minimum!', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error)),
        const SizedBox(height: 12),
        if (!alreadyMarked) Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => onMark(true),
            icon: const Icon(Icons.check, size: 16, color: AppColors.success),
            label: const Text('Present', style: TextStyle(color: AppColors.success)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.success)),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => onMark(false),
            icon: const Icon(Icons.close, size: 16, color: AppColors.error),
            label: const Text('Absent', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
          )),
        ]) else
          Text('✅ Attendance marked for today', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success)),
      ]),
    );
  }
}
