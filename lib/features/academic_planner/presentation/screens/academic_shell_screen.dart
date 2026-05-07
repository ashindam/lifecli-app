import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'class_routine_screen.dart';
import 'exam_calendar_screen.dart';
import 'assignments_screen.dart';
import 'attendance_screen.dart';

class AcademicShellScreen extends StatefulWidget {
  const AcademicShellScreen({super.key});

  @override
  State<AcademicShellScreen> createState() => _AcademicShellScreenState();
}

class _AcademicShellScreenState extends State<AcademicShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.grid_view_rounded, label: 'Routine'),
    _TabItem(icon: Icons.event_rounded, label: 'Exams'),
    _TabItem(icon: Icons.assignment_rounded, label: 'Tasks'),
    _TabItem(icon: Icons.check_circle_outline_rounded, label: 'Attendance'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Academic Planner',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: _tabs
              .map((t) => Tab(
                    icon: Icon(t.icon, size: 20),
                    text: t.label,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ClassRoutineScreen(),
          ExamCalendarScreen(),
          AssignmentsScreen(),
          AttendanceScreen(),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
