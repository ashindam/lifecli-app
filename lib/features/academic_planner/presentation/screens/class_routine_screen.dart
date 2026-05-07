import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

// ── Mock data ──────────────────────────────────────────────────────────────
class ClassEntry {
  final String id;
  final String course;
  final String day; // Mon, Tue, …
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room;
  final String teacher;
  final Color color;

  const ClassEntry({
    required this.id,
    required this.course,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacher,
    required this.color,
  });
}

final _mockClasses = [
  ClassEntry(
    id: '1',
    course: 'Data Structures',
    day: 'Sun',
    startTime: const TimeOfDay(hour: 8, minute: 0),
    endTime: const TimeOfDay(hour: 9, minute: 30),
    room: 'CS-101',
    teacher: 'Dr. Rahman',
    color: AppColors.primary,
  ),
  ClassEntry(
    id: '2',
    course: 'Algorithms',
    day: 'Sun',
    startTime: const TimeOfDay(hour: 10, minute: 0),
    endTime: const TimeOfDay(hour: 11, minute: 30),
    room: 'CS-202',
    teacher: 'Prof. Islam',
    color: AppColors.accent,
  ),
  ClassEntry(
    id: '3',
    course: 'Database',
    day: 'Mon',
    startTime: const TimeOfDay(hour: 8, minute: 0),
    endTime: const TimeOfDay(hour: 9, minute: 30),
    room: 'CS-103',
    teacher: 'Dr. Hossain',
    color: AppColors.success,
  ),
  ClassEntry(
    id: '4',
    course: 'Networks',
    day: 'Tue',
    startTime: const TimeOfDay(hour: 11, minute: 0),
    endTime: const TimeOfDay(hour: 12, minute: 30),
    room: 'CS-301',
    teacher: 'Prof. Ali',
    color: AppColors.info,
  ),
  ClassEntry(
    id: '5',
    course: 'Software Eng.',
    day: 'Wed',
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 10, minute: 30),
    room: 'CS-204',
    teacher: 'Dr. Khan',
    color: const Color(0xFF8B5CF6),
  ),
  ClassEntry(
    id: '6',
    course: 'Data Structures',
    day: 'Thu',
    startTime: const TimeOfDay(hour: 8, minute: 0),
    endTime: const TimeOfDay(hour: 9, minute: 30),
    room: 'CS-101',
    teacher: 'Dr. Rahman',
    color: AppColors.primary,
  ),
];

const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  bool _isGridView = true;
  List<ClassEntry> _classes = List.from(_mockClasses);

  String _todayShort() {
    const map = {
      1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu',
      5: 'Fri', 6: 'Sat', 7: 'Sun',
    };
    return map[DateTime.now().weekday]!;
  }

  ClassEntry? _nextClass() {
    final now = DateTime.now();
    final today = _todayShort();
    final todayClasses = _classes
        .where((c) => c.day == today)
        .where((c) =>
            c.startTime.hour > now.hour ||
            (c.startTime.hour == now.hour && c.startTime.minute > now.minute))
        .toList()
      ..sort((a, b) => a.startTime.hour * 60 +
          a.startTime.minute -
          (b.startTime.hour * 60 + b.startTime.minute));
    return todayClasses.isEmpty ? null : todayClasses.first;
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  void _showAddClassSheet() {
    final courseCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    String selectedDay = 'Sun';
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 30);
    Color selectedColor = AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Class',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Course Name', prefixIcon: Icon(Icons.book)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: _days
                      .map((d) =>
                          DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setS(() => selectedDay = v!),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: startTime);
                        if (t != null) setS(() => startTime = t);
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'Start Time'),
                        child:
                            Text(_formatTime(startTime), style: GoogleFonts.inter()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: endTime);
                        if (t != null) setS(() => endTime = t);
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(labelText: 'End Time'),
                        child:
                            Text(_formatTime(endTime), style: GoogleFonts.inter()),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: roomCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Room', prefixIcon: Icon(Icons.room)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Teacher',
                      prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                Text('Color',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.success,
                    AppColors.info,
                    const Color(0xFF8B5CF6),
                    AppColors.error,
                  ]
                      .map((c) => GestureDetector(
                            onTap: () => setS(() => selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: selectedColor == c
                                    ? Border.all(
                                        color: Colors.white, width: 2)
                                    : null,
                                boxShadow: selectedColor == c
                                    ? [
                                        BoxShadow(
                                            color: c.withOpacity(0.5),
                                            blurRadius: 6)
                                      ]
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (courseCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _classes.add(ClassEntry(
                          id: DateTime.now().toString(),
                          course: courseCtrl.text.trim(),
                          day: selectedDay,
                          startTime: startTime,
                          endTime: endTime,
                          room: roomCtrl.text.trim(),
                          teacher: teacherCtrl.text.trim(),
                          color: selectedColor,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Class'),
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
    final next = _nextClass();

    return Scaffold(
      body: Column(
        children: [
          // Next class banner
          if (next != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: next.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: next.color.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.alarm, color: next.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next Class',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: next.color,
                                fontWeight: FontWeight.w600)),
                        Text(
                          '${next.course} · ${_formatTime(next.startTime)} · ${next.room}',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Toggle row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.filledTonal(
                  onPressed: () => setState(() => _isGridView = true),
                  icon: const Icon(Icons.grid_view_rounded),
                  isSelected: _isGridView,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _isGridView ? AppColors.primaryContainer : null,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _isGridView = false),
                  icon: const Icon(Icons.list_rounded),
                  isSelected: !_isGridView,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        !_isGridView ? AppColors.primaryContainer : null,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _days.length * 120.0,
        child: Column(
          children: [
            // Day headers
            Row(
              children: _days
                  .map((d) => SizedBox(
                        width: 120,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: d == _todayShort()
                                  ? AppColors.primary
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: d == _todayShort()
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _days.map((day) {
                    final dayClasses = _classes
                        .where((c) => c.day == day)
                        .toList()
                      ..sort((a, b) =>
                          a.startTime.hour * 60 +
                          a.startTime.minute -
                          (b.startTime.hour * 60 + b.startTime.minute));
                    return SizedBox(
                      width: 120,
                      child: Column(
                        children: dayClasses.isEmpty
                            ? [
                                Container(
                                  height: 60,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('—',
                                        style: GoogleFonts.inter(
                                            color: Colors.grey)),
                                  ),
                                )
                              ]
                            : dayClasses
                                .map((c) => _GridClassCard(entry: c,
                                    formatTime: _formatTime))
                                .toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final sorted = List<ClassEntry>.from(_classes)
      ..sort((a, b) {
        final dayOrder = _days.indexOf(a.day) - _days.indexOf(b.day);
        if (dayOrder != 0) return dayOrder;
        return a.startTime.hour * 60 +
            a.startTime.minute -
            (b.startTime.hour * 60 + b.startTime.minute);
      });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = sorted[i];
        return Card(
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.class_rounded, color: c.color, size: 22),
            ),
            title: Text(c.course,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${c.day} · ${_formatTime(c.startTime)}–${_formatTime(c.endTime)} · ${c.room}',
                style: GoogleFonts.inter(fontSize: 12)),
            trailing: Text(c.teacher,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF64748B))),
          ),
        );
      },
    );
  }
}

class _GridClassCard extends StatelessWidget {
  final ClassEntry entry;
  final String Function(TimeOfDay) formatTime;
  const _GridClassCard({required this.entry, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: entry.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: entry.color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.course,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: entry.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(formatTime(entry.startTime),
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF64748B))),
          Text(entry.room,
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
