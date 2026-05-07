import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum AssignmentStatus { notStarted, inProgress, done, submitted }

extension AssignmentStatusExt on AssignmentStatus {
  String get label {
    switch (this) {
      case AssignmentStatus.notStarted: return 'Not Started';
      case AssignmentStatus.inProgress: return 'In Progress';
      case AssignmentStatus.done:       return 'Done';
      case AssignmentStatus.submitted:  return 'Submitted';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentStatus.notStarted: return AppColors.error;
      case AssignmentStatus.inProgress: return AppColors.accent;
      case AssignmentStatus.done:       return AppColors.success;
      case AssignmentStatus.submitted:  return AppColors.primary;
    }
  }

  IconData get icon {
    switch (this) {
      case AssignmentStatus.notStarted: return Icons.radio_button_unchecked;
      case AssignmentStatus.inProgress: return Icons.pending_rounded;
      case AssignmentStatus.done:       return Icons.check_circle_outline;
      case AssignmentStatus.submitted:  return Icons.check_circle_rounded;
    }
  }
}

class AssignmentEntry {
  final String id;
  final String course;
  final String title;
  final double weightage;
  final DateTime dueDate;
  final String submissionType;
  AssignmentStatus status;

  AssignmentEntry({
    required this.id,
    required this.course,
    required this.title,
    required this.weightage,
    required this.dueDate,
    required this.submissionType,
    this.status = AssignmentStatus.notStarted,
  });

  // Urgency = days until due * (1 / weightage) — lower is more urgent
  double get urgencyScore {
    final days = dueDate.difference(DateTime.now()).inHours / 24;
    if (days < 0) return -1;
    return days / (weightage + 1);
  }
}

final _mockAssignments = [
  AssignmentEntry(
    id: '1',
    course: 'Data Structures',
    title: 'BST Implementation',
    weightage: 25,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    submissionType: 'Code + Report',
    status: AssignmentStatus.inProgress,
  ),
  AssignmentEntry(
    id: '2',
    course: 'Algorithms',
    title: 'Sorting Analysis Report',
    weightage: 15,
    dueDate: DateTime.now().add(const Duration(days: 5)),
    submissionType: 'PDF',
    status: AssignmentStatus.notStarted,
  ),
  AssignmentEntry(
    id: '3',
    course: 'Database',
    title: 'ER Diagram Assignment',
    weightage: 30,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    submissionType: 'PDF Upload',
    status: AssignmentStatus.notStarted,
  ),
  AssignmentEntry(
    id: '4',
    course: 'Networks',
    title: 'TCP/IP Presentation',
    weightage: 10,
    dueDate: DateTime.now().add(const Duration(days: 8)),
    submissionType: 'Slides',
    status: AssignmentStatus.done,
  ),
  AssignmentEntry(
    id: '5',
    course: 'Software Eng.',
    title: 'SRS Document',
    weightage: 20,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    submissionType: 'Doc',
    status: AssignmentStatus.submitted,
  ),
];

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late List<AssignmentEntry> _assignments;
  AssignmentStatus? _filter;

  @override
  void initState() {
    super.initState();
    _assignments = List.from(_mockAssignments);
  }

  List<AssignmentEntry> get _filtered {
    final list = _filter == null
        ? List<AssignmentEntry>.from(_assignments)
        : _assignments.where((a) => a.status == _filter).toList();
    list.sort((a, b) => a.urgencyScore.compareTo(b.urgencyScore));
    return list;
  }

  String _dueDateLabel(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  Color _dueDateColor(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return AppColors.error;
    if (diff <= 1) return AppColors.error;
    if (diff <= 3) return AppColors.accent;
    return AppColors.success;
  }

  void _cycleStatus(AssignmentEntry a) {
    final values = AssignmentStatus.values;
    final next = values[(values.indexOf(a.status) + 1) % values.length];
    setState(() => a.status = next);
  }

  void _showAddSheet() {
    final courseCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    AssignmentStatus status = AssignmentStatus.notStarted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('Add Assignment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Course', prefixIcon: Icon(Icons.book))),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Assignment Title', prefixIcon: Icon(Icons.assignment))),
                const SizedBox(height: 12),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weightage (%)', prefixIcon: Icon(Icons.percent)),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setS(() => dueDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Due Date', prefixIcon: Icon(Icons.calendar_today)),
                    child: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}', style: GoogleFonts.inter()),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Submission Type', prefixIcon: Icon(Icons.upload_file))),
                const SizedBox(height: 12),
                DropdownButtonFormField<AssignmentStatus>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: AssignmentStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) => setS(() => status = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (courseCtrl.text.isEmpty || titleCtrl.text.isEmpty) return;
                      setState(() {
                        _assignments.add(AssignmentEntry(
                          id: DateTime.now().toString(),
                          course: courseCtrl.text.trim(),
                          title: titleCtrl.text.trim(),
                          weightage: double.tryParse(weightCtrl.text) ?? 10,
                          dueDate: dueDate,
                          submissionType: subCtrl.text.trim(),
                          status: status,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Assignment'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      body: Column(
        children: [
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                ...AssignmentStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: s.label,
                    selected: _filter == s,
                    color: s.color,
                    onTap: () => setState(() => _filter = _filter == s ? null : s),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No assignments', style: GoogleFonts.inter(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return Dismissible(
                        key: Key(a.id),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.swap_horiz, color: AppColors.success),
                        ),
                        confirmDismiss: (_) async {
                          _cycleStatus(a);
                          return false;
                        },
                        child: _AssignmentCard(
                          assignment: a,
                          dueDateLabel: _dueDateLabel(a.dueDate),
                          dueDateColor: _dueDateColor(a.dueDate),
                          onStatusTap: () => _cycleStatus(a),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentEntry assignment;
  final String dueDateLabel;
  final Color dueDateColor;
  final VoidCallback onStatusTap;

  const _AssignmentCard({
    required this.assignment,
    required this.dueDateLabel,
    required this.dueDateColor,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(assignment.course,
                                style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ),
                          if (assignment.weightage > 20) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_rounded, size: 10, color: AppColors.error),
                                  const SizedBox(width: 3),
                                  Text('High Stakes',
                                      style: GoogleFonts.inter(
                                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(assignment.title,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onStatusTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: assignment.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: assignment.status.color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(assignment.status.icon, size: 12, color: assignment.status.color),
                        const SizedBox(width: 4),
                        Text(assignment.status.label,
                            style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700, color: assignment.status.color)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.percent_rounded, size: 13, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text('${assignment.weightage.toStringAsFixed(0)}% weightage',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                const Spacer(),
                Icon(Icons.upload_file_rounded, size: 13, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(assignment.submissionType,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: dueDateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(dueDateLabel,
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600, color: dueDateColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.15) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? c : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
