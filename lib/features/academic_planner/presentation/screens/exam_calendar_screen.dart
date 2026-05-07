import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

enum ExamType { midterm, finalExam, quiz, lab }

extension ExamTypeExt on ExamType {
  String get label {
    switch (this) {
      case ExamType.midterm:    return 'Midterm';
      case ExamType.finalExam:  return 'Final';
      case ExamType.quiz:       return 'Quiz';
      case ExamType.lab:        return 'Lab';
    }
  }

  Color get color {
    switch (this) {
      case ExamType.midterm:    return AppColors.error;
      case ExamType.finalExam:  return AppColors.primary;
      case ExamType.quiz:       return AppColors.accent;
      case ExamType.lab:        return AppColors.success;
    }
  }
}

class ExamEntry {
  final String id;
  final String course;
  final DateTime date;
  final TimeOfDay time;
  final String venue;
  final ExamType type;

  const ExamEntry({
    required this.id,
    required this.course,
    required this.date,
    required this.time,
    required this.venue,
    required this.type,
  });
}

final _now = DateTime.now();

final _mockExams = [
  ExamEntry(
    id: '1',
    course: 'Data Structures',
    date: DateTime(_now.year, _now.month, _now.day + 3),
    time: const TimeOfDay(hour: 9, minute: 0),
    venue: 'Exam Hall A',
    type: ExamType.midterm,
  ),
  ExamEntry(
    id: '2',
    course: 'Algorithms',
    date: DateTime(_now.year, _now.month, _now.day + 7),
    time: const TimeOfDay(hour: 11, minute: 0),
    venue: 'Room 201',
    type: ExamType.quiz,
  ),
  ExamEntry(
    id: '3',
    course: 'Database',
    date: DateTime(_now.year, _now.month, _now.day + 14),
    time: const TimeOfDay(hour: 14, minute: 0),
    venue: 'Exam Hall B',
    type: ExamType.finalExam,
  ),
  ExamEntry(
    id: '4',
    course: 'Networks Lab',
    date: DateTime(_now.year, _now.month, _now.day + 5),
    time: const TimeOfDay(hour: 13, minute: 0),
    venue: 'CS Lab 2',
    type: ExamType.lab,
  ),
];

class ExamCalendarScreen extends StatefulWidget {
  const ExamCalendarScreen({super.key});

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ExamEntry> _exams = List.from(_mockExams);

  List<ExamEntry> _eventsForDay(DateTime day) {
    return _exams
        .where((e) => isSameDay(e.date, day))
        .toList();
  }

  String _countdown(DateTime examDate) {
    final diff = examDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Past';
    if (diff == 0) return 'Today!';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  Color _countdownColor(DateTime examDate) {
    final diff = examDate.difference(DateTime.now()).inDays;
    if (diff <= 0) return AppColors.error;
    if (diff <= 3) return AppColors.error;
    if (diff <= 7) return AppColors.accent;
    return AppColors.success;
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _showAddExamSheet() {
    final courseCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    ExamType selectedType = ExamType.midterm;

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
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                const SizedBox(height: 16),
                Text('Add Exam', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExamType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Exam Type'),
                  items: ExamType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: t.color, shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ]),
                          ))
                      .toList(),
                  onChanged: (v) => setS(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setS(() => selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final t = await showTimePicker(
                        context: ctx, initialTime: selectedTime);
                    if (t != null) setS(() => selectedTime = t);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(_formatTime(selectedTime), style: GoogleFonts.inter()),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (courseCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _exams.add(ExamEntry(
                          id: DateTime.now().toString(),
                          course: courseCtrl.text.trim(),
                          date: selectedDate,
                          time: selectedTime,
                          venue: venueCtrl.text.trim(),
                          type: selectedType,
                        ));
                        _exams.sort((a, b) => a.date.compareTo(b.date));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Exam'),
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
    final displayed = _selectedDay != null
        ? _eventsForDay(_selectedDay!)
        : (List<ExamEntry>.from(_exams)..sort((a, b) => a.date.compareTo(b.date)));

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<ExamEntry>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            eventLoader: _eventsForDay,
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            onDaySelected: (sel, foc) => setState(() {
              _selectedDay = isSameDay(_selectedDay, sel) ? null : sel;
              _focusedDay = foc;
            }),
            onPageChanged: (foc) => setState(() => _focusedDay = foc),
          ),
          const Divider(height: 1),
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Text('No exams',
                        style: GoogleFonts.inter(color: Colors.grey)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ExamCard(
                      exam: displayed[i],
                      countdown: _countdown(displayed[i].date),
                      countdownColor: _countdownColor(displayed[i].date),
                      formatTime: _formatTime,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExamSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamEntry exam;
  final String countdown;
  final Color countdownColor;
  final String Function(TimeOfDay) formatTime;

  const _ExamCard({
    required this.exam,
    required this.countdown,
    required this.countdownColor,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: exam.type.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${exam.date.day}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: exam.type.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(exam.course,
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: exam.type.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(exam.type.label,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: exam.type.color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatTime(exam.time)} · ${exam.venue}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: countdownColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: countdownColor.withOpacity(0.4)),
              ),
              child: Text(countdown,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: countdownColor)),
            ),
          ],
        ),
      ),
    );
  }
}
