import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:lifecli_app/core/constants/app_colors.dart';
import 'package:lifecli_app/core/services/google_auth_service.dart';

// ─── Dummy data models ─────────────────────────────────────────────────────

class _DummyClass {
  const _DummyClass(this.course, this.time, this.room);
  final String course;
  final String time;
  final String room;
}

class _DummyDeadline {
  const _DummyDeadline(this.title, this.course, this.daysLeft);
  final String title;
  final String course;
  final int daysLeft;
}

class _DummyTask {
  _DummyTask(this.title, this.course, this.priority, {this.completed = false});
  final String title;
  final String course;
  final String priority;
  bool completed;
}

// ─── Dashboard Screen ──────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  // Dummy data
  final _nextClass = const _DummyClass(
    'Algorithm & Complexity',
    '10:00 AM – 11:30 AM',
    'Room 301, CSE Block',
  );

  final _deadlines = [
    const _DummyDeadline('DSP Lab Report', 'EEE 3204', 1),
    const _DummyDeadline('Physics Final', 'PHY 1101', 4),
    const _DummyDeadline('OOP Project', 'CSE 2105', 7),
    const _DummyDeadline('Math Assignment', 'MATH 2201', 12),
    const _DummyDeadline('Database Design', 'CSE 3302', 18),
  ];

  late List<_DummyTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [
      _DummyTask('Complete DSP lab report', 'EEE 3204', 'Critical'),
      _DummyTask('Study chapter 5 — Dynamic Programming', 'CSE 3105', 'High'),
      _DummyTask('Pay semester fee', 'Admin', 'High'),
    ];
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isLoading = false);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = GoogleAuthService.displayName;
    if (name == null || name.isEmpty) return 'Student';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Gradient header with greeting + quick stats
            _buildGradientHeader(context),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  // Next class card — indigo gradient glass
                  _NextClassCard(classInfo: _nextClass),
                  const SizedBox(height: 12),
                  // Exam countdown + load shedding row
                  _InfoChipsRow(),
                  const SizedBox(height: 20),
                  // Summary cards
                  _SummaryCardsSection(),
                  const SizedBox(height: 20),
                  // Deadlines section
                  _SectionHeader(
                    title: 'Upcoming Deadlines',
                    icon: Icons.event_rounded,
                    iconColor: AppColors.error,
                    onSeeAll: () => context.go('/academic/planner'),
                  ),
                  const SizedBox(height: 8),
                  _DeadlinesStrip(deadlines: _deadlines),
                  const SizedBox(height: 20),
                  // Today's tasks
                  _SectionHeader(
                    title: "Today's Tasks",
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.primary,
                    onSeeAll: () => context.pushNamed('tasks'),
                  ),
                  const SizedBox(height: 8),
                  _TodaysTasksList(
                    tasks: _tasks,
                    onComplete: (i) =>
                        setState(() => _tasks[i].completed = true),
                    onDelete: (i) => setState(() => _tasks.removeAt(i)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header ────────────────────────────────────────────────────────
  Widget _buildGradientHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar + greeting + bell
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.pushNamed('profile'),
                      child: _ProfileAvatar(
                        photoUrl: GoogleAuthService.photoUrl,
                        name: _firstName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $_firstName 👋',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy')
                                .format(DateTime.now()),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white70),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick stats row
                _QuickStatsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Quick Stats Row ───────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Tasks Done',
            value: '5',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Study Hours',
            value: '3.5h',
            icon: Icons.menu_book_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Streak',
            value: '14 🔥',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Avatar ────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.photoUrl, required this.name});
  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white.withOpacity(0.2),
        backgroundImage: NetworkImage(photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white.withOpacity(0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Next Class Card — indigo gradient with glass ──────────────────────────

class _NextClassCard extends StatelessWidget {
  const _NextClassCard({required this.classInfo});
  final _DummyClass classInfo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.class_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Class',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.75),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      classInfo.course,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${classInfo.time}  ·  ${classInfo.room}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info chips row ────────────────────────────────────────────────────────

class _InfoChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.event_rounded,
            label: 'Physics Final',
            value: 'in 4 days',
            color: AppColors.error,
            bgColor: AppColors.errorContainer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoChip(
            icon: Icons.power_off_rounded,
            label: 'Load Shedding',
            value: '2PM – 4PM',
            color: AppColors.warning,
            bgColor: AppColors.warningContainer,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Cards Section ─────────────────────────────────────────────────

class _SummaryCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _TasksSummaryCard(),
          const SizedBox(width: 12),
          _ExpensesSummaryCard(),
          const SizedBox(width: 12),
          _AllowanceSummaryCard(),
          const SizedBox(width: 12),
          _HabitsSummaryCard(),
          const SizedBox(width: 12),
          _LoansSummaryCard(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.child,
  });
  final String title;
  final Color color;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 160,
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          right: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _TasksSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      title: 'Tasks',
      color: AppColors.primary,
      icon: Icons.check_circle_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '7',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 4),
                child: Text(
                  'pending',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '2 overdue',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensesSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const spent = 3240.0;
    const budget = 8000.0;
    final progress = spent / budget;

    return _SummaryCard(
      title: 'Expenses',
      color: AppColors.success,
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '৳3,240 ',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
                TextSpan(
                  text: 'of ৳8,000',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.successContainer,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllowanceSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      title: 'Allowance',
      color: AppColors.accent,
      icon: Icons.savings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '৳4,760 left',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accentDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '18 days · ৳264/day',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      title: 'Habits',
      color: AppColors.info,
      icon: Icons.local_fire_department_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HabitRow(name: 'Morning run', streak: 14),
          _HabitRow(name: 'Read 30 min', streak: 7),
          _HabitRow(name: 'No junk food', streak: 3),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.name, required this.streak});
  final String name;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
                fontSize: 10, color: const Color(0xFF475569)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$streak',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _LoansSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const balance = 500.0;
    final isPositive = balance >= 0;

    return _SummaryCard(
      title: 'Loans',
      color: isPositive ? AppColors.success : AppColors.error,
      icon: Icons.handshake_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPositive
                ? '+৳${balance.toInt()}'
                : '-৳${balance.abs().toInt()}',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isPositive ? AppColors.success : AppColors.error,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPositive ? 'Net owed to you' : 'Net you owe',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.icon,
    this.iconColor,
    this.onSeeAll,
  });
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See all',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Deadlines Strip ───────────────────────────────────────────────────────

class _DeadlinesStrip extends StatelessWidget {
  const _DeadlinesStrip({required this.deadlines});
  final List<_DummyDeadline> deadlines;

  Color _urgencyColor(int days) {
    if (days <= 2) return AppColors.deadlineUrgent;
    if (days <= 7) return AppColors.deadlineSoon;
    return AppColors.deadlineLater;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deadlines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = deadlines[i];
          final color = _urgencyColor(d.daysLeft);
          return _DeadlineCard(deadline: d, color: color);
        },
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.deadline, required this.color});
  final _DummyDeadline deadline;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(color: color.withOpacity(0.25)),
          right: BorderSide(color: color.withOpacity(0.25)),
          bottom: BorderSide(color: color.withOpacity(0.25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            deadline.title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0F172A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  deadline.course,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deadline.daysLeft <= 0
                      ? 'Today'
                      : '${deadline.daysLeft}d',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Today's Tasks List ────────────────────────────────────────────────────

class _TodaysTasksList extends StatelessWidget {
  const _TodaysTasksList({
    required this.tasks,
    required this.onComplete,
    required this.onDelete,
  });
  final List<_DummyTask> tasks;
  final void Function(int) onComplete;
  final void Function(int) onDelete;

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return AppColors.priorityCritical;
      case 'High':
        return AppColors.priorityHigh;
      case 'Medium':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 40),
            const SizedBox(height: 8),
            Text(
              'All tasks done! 🎉',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        final i = entry.key;
        final task = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: Key('task_$i${task.title}'),
            background: _DismissBackground(
              color: AppColors.success,
              icon: Icons.check_rounded,
              alignment: Alignment.centerLeft,
              label: 'Complete',
            ),
            secondaryBackground: _DismissBackground(
              color: AppColors.error,
              icon: Icons.delete_rounded,
              alignment: Alignment.centerRight,
              label: 'Delete',
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                onComplete(i);
              } else {
                onDelete(i);
              }
            },
            child: _TaskListTile(
                task: task,
                priorityColor: _priorityColor(task.priority)),
          ),
        );
      }).toList(),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({
    required this.color,
    required this.icon,
    required this.alignment,
    required this.label,
  });
  final Color color;
  final IconData icon;
  final Alignment alignment;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ] else ...[
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(icon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  const _TaskListTile({
    required this.task,
    required this.priorityColor,
  });
  final _DummyTask task;
  final Color priorityColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: priorityColor, width: 3),
          top: BorderSide(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
          right: BorderSide(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // Checkbox
          Icon(
            task.completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color:
                task.completed ? AppColors.success : const Color(0xFF94A3B8),
            size: 22,
          ),
          const SizedBox(width: 10),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.completed
                        ? const Color(0xFF94A3B8)
                        : (isDark
                            ? Colors.white
                            : const Color(0xFF0F172A)),
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task.course,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Priority chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.priority,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: priorityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
