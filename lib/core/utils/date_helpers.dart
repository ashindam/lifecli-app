import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('d MMM, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _shortDateFormat = DateFormat('d MMM');
  static final DateFormat _dayNameFormat = DateFormat('EEEE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String formatDate(DateTime date) => _displayFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatTime(DateTime time) => _timeFormat.format(time);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String formatDayName(DateTime date) => _dayNameFormat.format(date);
  static String toIso(DateTime date) => _dateFormat.format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isBefore(today);
  }

  static bool isDueThisWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(today) && d.isBefore(today.add(const Duration(days: 7)));
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(today).inDays;
  }

  static String relativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    final days = daysUntil(date);
    if (days == 1) return 'Tomorrow';
    if (days > 1 && days <= 7) return 'In $days days';
    if (days < 0) return '${-days} day${-days == 1 ? '' : 's'} ago';
    return formatShortDate(date);
  }

  static String countdownText(DateTime date) {
    final days = daysUntil(date);
    if (days == 0) return 'Today!';
    if (days == 1) return 'Tomorrow';
    if (days > 0) return 'In $days days';
    return 'Overdue ${-days} day${-days == 1 ? '' : 's'} ago';
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static int daysLeftInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }

  static DateTime startOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  static DateTime endOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59);
  }

  static DateTime startOfWeek([DateTime? date]) {
    final d = date ?? DateTime.now();
    final diff = d.weekday - 1;
    return DateTime(d.year, d.month, d.day - diff);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameWeek(DateTime date, DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && d.isBefore(end);
  }

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
