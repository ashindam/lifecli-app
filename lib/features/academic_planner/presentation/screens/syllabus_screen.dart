import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/syllabus_models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

final _syllabusProvider = StateNotifierProvider<_SyllabusNotifier, List<SyllabusCourseModel>>(
  (ref) => _SyllabusNotifier(),
);

class _SyllabusNotifier extends StateNotifier<List<SyllabusCourseModel>> {
  _SyllabusNotifier() : super([]) { _load(); }
  void _load() { state = HiveService.syllabusCourses.values.whereType<SyllabusCourseModel>().toList(); }
  Future<void> addCourse(SyllabusCourseModel c) async { await HiveService.syllabusCourses.put(c.id, c); _load(); }
  Future<void> addTopic(String courseId, String topicName) async {
    final c = state.firstWhere((c) => c.id == courseId);
    final updated = c.copyWith(topics: [...c.topics, SyllabusTopicModel(courseId: courseId, topicName: topicName)]);
    await HiveService.syllabusCourses.put(courseId, updated); _load();
  }
  Future<void> updateTopicStatus(String courseId, String topicId, int status) async {
    final c = state.firstWhere((c) => c.id == courseId);
    final topics = c.topics.map((t) => t.id == topicId ? t.copyWith(status: status) : t).toList();
    await HiveService.syllabusCourses.put(courseId, c.copyWith(topics: topics)); _load();
  }
  Future<void> toggleStar(String courseId, String topicId) async {
    final c = state.firstWhere((c) => c.id == courseId);
    final topics = c.topics.map((t) => t.id == topicId ? t.copyWith(isStarred: !t.isStarred) : t).toList();
    await HiveService.syllabusCourses.put(courseId, c.copyWith(topics: topics)); _load();
  }
}

class SyllabusScreen extends ConsumerWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(_syllabusProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Syllabus Tracker', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: courses.isEmpty
          ? const EmptyState(emoji: '📖', title: 'No courses yet', subtitle: 'Add courses to track your syllabus')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: courses.length,
              itemBuilder: (ctx, i) => _CourseSection(
                course: courses[i],
                onAddTopic: (name) => ref.read(_syllabusProvider.notifier).addTopic(courses[i].id, name),
                onStatus: (tid, s) => ref.read(_syllabusProvider.notifier).updateTopicStatus(courses[i].id, tid, s),
                onStar: (tid) => ref.read(_syllabusProvider.notifier).toggleStar(courses[i].id, tid),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCourseSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Course'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _addCourseSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Course', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Course Name')),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              ref.read(_syllabusProvider.notifier).addCourse(SyllabusCourseModel(courseName: ctrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          )),
        ]),
      ),
    );
  }
}

class _CourseSection extends StatefulWidget {
  final SyllabusCourseModel course;
  final ValueChanged<String> onAddTopic;
  final void Function(String, int) onStatus;
  final ValueChanged<String> onStar;
  const _CourseSection({required this.course, required this.onAddTopic, required this.onStatus, required this.onStar});
  @override State<_CourseSection> createState() => _CourseSectionState();
}

class _CourseSectionState extends State<_CourseSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final topics = widget.course.topics;
    final covered = topics.where((t) => t.status == 2).length;
    final progress = topics.isNotEmpty ? covered / topics.length : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.course.courseName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: AppColors.primaryContainer,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success))),
                  const SizedBox(width: 10),
                  Text('$covered/${topics.length}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ])),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1),
          ...topics.map((t) => ListTile(
            leading: GestureDetector(
              onTap: () => widget.onStatus(t.id, (t.status + 1) % 3),
              child: Text(['❌','📖','✅'][t.status], style: const TextStyle(fontSize: 22)),
            ),
            title: Text(t.topicName, style: GoogleFonts.inter(fontSize: 14,
              decoration: t.status == 2 ? TextDecoration.lineThrough : null,
              color: t.status == 2 ? Colors.grey : null)),
            trailing: GestureDetector(
              onTap: () => widget.onStar(t.id),
              child: Icon(t.isStarred ? Icons.star : Icons.star_outline, color: t.isStarred ? AppColors.warning : Colors.grey, size: 20),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          )),
          TextButton.icon(
            onPressed: () => _addTopicSheet(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Topic'),
          ),
        ],
      ]),
    );
  }

  void _addTopicSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Topic to ${widget.course.courseName}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Topic Name')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () { if (ctrl.text.trim().isNotEmpty) { widget.onAddTopic(ctrl.text.trim()); Navigator.pop(ctx); } },
            child: const Text('Add'),
          )),
        ]),
      ),
    );
  }
}
