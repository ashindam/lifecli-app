import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../utils/date_helpers.dart';

class DeadlineItem {
  final String id;
  final String title;
  final DateTime date;
  final String type; // task, exam, assignment, bill
  final String? subtitle;

  const DeadlineItem({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.subtitle,
  });
}

class DeadlineStrip extends StatelessWidget {
  final List<DeadlineItem> items;
  final ValueChanged<DeadlineItem>? onTap;

  const DeadlineStrip({super.key, required this.items, this.onTap});

  Color _colorForDays(int days) {
    if (days <= 2) return AppColors.deadlineUrgent;
    if (days <= 7) return AppColors.deadlineSoon;
    return AppColors.deadlineLater;
  }

  String _typeEmoji(String type) {
    switch (type) {
      case 'exam': return '📝';
      case 'assignment': return '📋';
      case 'bill': return '💸';
      case 'task': return '✅';
      default: return '📌';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            '🎉 No upcoming deadlines',
            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }

    final sorted = [...items]..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = sorted[i];
          final days = DateHelpers.daysUntil(item.date);
          final color = _colorForDays(days);
          return GestureDetector(
            onTap: () => onTap?.call(item),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_typeEmoji(item.type), style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          days == 0 ? 'Today' : days < 0 ? '${-days}d ago' : '${days}d',
                          style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700, color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateHelpers.formatShortDate(item.date),
                    style: GoogleFonts.inter(fontSize: 10, color: color),
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
