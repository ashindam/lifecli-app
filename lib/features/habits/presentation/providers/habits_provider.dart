import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/habit_model.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';

class HabitsState {
  final List<HabitModel> habits;
  final List<HabitLogModel> logs;

  const HabitsState({this.habits = const [], this.logs = const []});

  HabitsState copyWith({List<HabitModel>? habits, List<HabitLogModel>? logs}) =>
      HabitsState(habits: habits ?? this.habits, logs: logs ?? this.logs);

  bool isCheckedInToday(String habitId) {
    final today = DateTime.now();
    return logs.any((l) =>
        l.habitId == habitId && DateHelpers.isSameDay(l.date, today) && l.isCheckedIn);
  }

  List<HabitLogModel> logsForHabit(String habitId) =>
      logs.where((l) => l.habitId == habitId).toList();

  List<HabitModel> get top3 {
    final sorted = [...habits]..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return sorted.take(3).toList();
  }
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier() : super(const HabitsState()) {
    _load();
  }

  void _load() {
    final habits = HiveService.habits.values.whereType<HabitModel>().toList();
    final logs = HiveService.habitLogs.values.whereType<HabitLogModel>().toList();
    state = HabitsState(habits: habits, logs: logs);
  }

  Future<void> addHabit(HabitModel habit) async {
    await HiveService.habits.put(habit.id, habit);
    state = state.copyWith(habits: [...state.habits, habit]);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await HiveService.habits.put(habit.id, habit);
    final updated = [...state.habits];
    final idx = updated.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) updated[idx] = habit;
    state = state.copyWith(habits: updated);
  }

  Future<void> deleteHabit(String id) async {
    await HiveService.habits.delete(id);
    // Also delete logs
    final logsToDelete = state.logs.where((l) => l.habitId == id).toList();
    for (final log in logsToDelete) await HiveService.habitLogs.delete(log.id);
    state = state.copyWith(
      habits: state.habits.where((h) => h.id != id).toList(),
      logs: state.logs.where((l) => l.habitId != id).toList(),
    );
  }

  Future<void> checkIn(String habitId, DateTime date) async {
    if (state.isCheckedInToday(habitId)) return; // Prevent duplicates

    final log = HabitLogModel(habitId: habitId, date: date, isCheckedIn: true);
    await HiveService.habitLogs.put(log.id, log);

    final habit = state.habits.firstWhere((h) => h.id == habitId);
    final newStreak = _calculateStreak(habitId, date);
    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
    );
    await HiveService.habits.put(habitId, updatedHabit);

    final updatedHabits = [...state.habits];
    final idx = updatedHabits.indexWhere((h) => h.id == habitId);
    if (idx >= 0) updatedHabits[idx] = updatedHabit;

    state = state.copyWith(
      habits: updatedHabits,
      logs: [...state.logs, log],
    );
  }

  Future<void> undoCheckIn(String habitId) async {
    final today = DateTime.now();
    final logToRemove = state.logs.lastWhere(
      (l) => l.habitId == habitId && DateHelpers.isSameDay(l.date, today),
      orElse: () => HabitLogModel(habitId: '', date: DateTime.now(), isCheckedIn: false),
    );
    if (logToRemove.habitId.isEmpty) return;

    await HiveService.habitLogs.delete(logToRemove.id);
    final remainingLogs = state.logs.where((l) => l.id != logToRemove.id).toList();

    final habit = state.habits.firstWhere((h) => h.id == habitId);
    final newStreak = _calculateStreak(habitId, today.subtract(const Duration(days: 1)));
    final updatedHabit = habit.copyWith(currentStreak: newStreak);
    await HiveService.habits.put(habitId, updatedHabit);

    final updatedHabits = [...state.habits];
    final idx = updatedHabits.indexWhere((h) => h.id == habitId);
    if (idx >= 0) updatedHabits[idx] = updatedHabit;

    state = state.copyWith(habits: updatedHabits, logs: remainingLogs);
  }

  int _calculateStreak(String habitId, DateTime upToDate) {
    var streak = 0;
    var date = DateTime(upToDate.year, upToDate.month, upToDate.day);
    while (true) {
      final hasLog = state.logs.any(
        (l) => l.habitId == habitId && DateHelpers.isSameDay(l.date, date) && l.isCheckedIn,
      );
      if (!hasLog) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>(
  (ref) => HabitsNotifier(),
);
