import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifecli_app/core/data/university_data.dart';
import 'package:lifecli_app/core/constants/app_colors.dart';

class UniversityPickerScreen extends StatefulWidget {
  const UniversityPickerScreen({super.key});

  @override
  State<UniversityPickerScreen> createState() => _UniversityPickerScreenState();
}

class _UniversityPickerScreenState extends State<UniversityPickerScreen> {
  String _search = '';
  String _selectedFilter = 'All';
  String? _selectedUniversityName;

  final List<String> _filters = ['All', 'Public', 'Private', 'Medical'];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedUniversityName = prefs.getString('university_name');
    });
  }

  Future<void> _selectUniversity(BdUniversity uni) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('university_name', uni.name);
    await prefs.setString('university_short', uni.shortName);
    await prefs.setString('university_type', uni.type);
    await prefs.setString('university_location', uni.location);
    await prefs.setString('grading_system_name', uni.gradingSystem.name);
    setState(() => _selectedUniversityName = uni.name);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${uni.shortName} selected!',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context, uni);
      });
    }
  }

  List<BdUniversity> get _filtered {
    return bangladeshiUniversities.where((u) {
      final matchesSearch = _search.isEmpty ||
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.shortName.toLowerCase().contains(_search.toLowerCase()) ||
          u.location.toLowerCase().contains(_search.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Medical' && u.category == 'Medical') ||
          (_selectedFilter != 'Medical' && u.type == _selectedFilter && u.category != 'Medical');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + title
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            'Select Your University',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filtered.length} unis',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search university or location...',
                            hintStyle: GoogleFonts.inter(
                                color: Colors.white60, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Colors.white60, size: 20),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter chips
                    Row(
                      children: _filters.map((f) {
                        final isActive = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                f,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? const Color(0xFF6366F1)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_outlined,
                            color: Colors.white30, size: 56),
                        const SizedBox(height: 12),
                        Text(
                          'No university found',
                          style: GoogleFonts.inter(
                              color: Colors.white38, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final uni = filtered[i];
                      final isSelected =
                          _selectedUniversityName == uni.name;
                      return _UniversityCard(
                        university: uni,
                        isSelected: isSelected,
                        onTap: () => _selectUniversity(uni),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── University Card ───────────────────────────────────────────────────────

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({
    required this.university,
    required this.isSelected,
    required this.onTap,
  });

  final BdUniversity university;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _typeColor {
    if (university.category == 'Medical') return const Color(0xFFEF4444);
    if (university.type == 'Public') return const Color(0xFF14B8A6);
    return const Color(0xFF6366F1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.18)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.07),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Short name badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _typeColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  university.shortName.length > 5
                      ? university.shortName.substring(0, 4)
                      : university.shortName,
                  style: GoogleFonts.inter(
                    fontSize: university.shortName.length > 4 ? 9 : 11,
                    fontWeight: FontWeight.w800,
                    color: _typeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.white38),
                      const SizedBox(width: 3),
                      Text(
                        university.location,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white38),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          university.type,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    university.gradingSystem.name,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.white30),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Grading System Sheet ──────────────────────────────────────────────────

class GradingSystemSheet extends StatelessWidget {
  const GradingSystemSheet({super.key, required this.gradingSystem});

  final GradingSystem gradingSystem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            gradingSystem.name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Table header
          _GradeRow(
            grade: 'Grade', points: 'GPA', range: 'Marks (%)',
            isHeader: true,
          ),
          const Divider(color: Colors.white12),
          ...gradingSystem.grades.map((g) => _GradeRow(
            grade: g.grade,
            points: g.points.toStringAsFixed(2),
            range: '${g.minPercent}–${g.maxPercent}',
          )),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.grade,
    required this.points,
    required this.range,
    this.isHeader = false,
  });

  final String grade;
  final String points;
  final String range;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: isHeader ? 11 : 13,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
      color: isHeader ? Colors.white38 : Colors.white70,
    );

    Color? gradeColor;
    if (!isHeader) {
      if (points.startsWith('4') || points.startsWith('3.7')) {
        gradeColor = const Color(0xFF14B8A6);
      } else if (points.startsWith('3')) {
        gradeColor = const Color(0xFF6366F1);
      } else if (points.startsWith('2')) {
        gradeColor = const Color(0xFFF59E0B);
      } else if (points == '0.00') {
        gradeColor = const Color(0xFFEF4444);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              grade,
              style: isHeader
                  ? style
                  : style.copyWith(
                      color: gradeColor ?? Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ),
          Expanded(child: Text(points, style: style)),
          Text(range, style: style),
        ],
      ),
    );
  }
}
