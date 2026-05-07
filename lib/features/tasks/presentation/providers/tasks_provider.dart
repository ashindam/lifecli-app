import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/task_model.dart';
import '../../../../core/services/hive_service.dart';

class TaskFilter {
  final int? priority;
  final int? status;
  final int? type;
  final int? energy;
  final bool showOverdueOnly;
  final bool showTodayOnly;
  final String searchQuery;

  const TaskFilter({
    this.priority,
    this.status,
    this.type,
    this.energy,
    this.showOverdueOnly = false,
    this.showTodayOnly = false,
    this.searchQuery = '',
  });

  bool get hasActiveFilter =>
      priority != null ||
      status != null ||
      type != null ||
      energy != null ||
      showOverdueOnly ||
      showTodayOnly ||
      searchQuery.isNotEmpty;

  TaskFilter copyWith({
    int? priority,
    int? status,
    int? type,
    int? energy,
    bool? showOverdueOnly,
    bool? showTodayOnly,
    String? searchQuery,
  }) => TaskFilter(
    priority: priority,
    status: status,
    type: type,
    energy: energy,
    showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
    showTodayOnly: showTodayOnly ?? this.showTodayOnly,
    searchQuery: searchQuery ?? this.searchQuery,
  );

  TaskFilter clear() => const TaskFilter();
}

enum TaskSort { priority, dueDate, createdDate, energyLevel }

class TasksState {
  final List<TaskModel> tasks;
  final TaskFilter filter;
  final TaskSort sort;

  const TasksState({
    this.tasks = const [],
    this.filter = const TaskFilter(),
    this.sort = TaskSort.priority,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    TaskFilter? filter,
    TaskSort? sort,
  }) => TasksState(
    tasks: tasks ?? this.tasks,
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
  );

  List<TaskModel> get filteredTasks {
    var result = tasks.where((t) {
      if (filter.priority != null && t.priority != filter.priority) return false;
      if (filter.status != null && t.status != filter.status) return false;
      if (filter.type != null && t.type != filter.type) return false;
      if (filter.energy != null && t.energy != filter.energy) return false;
      if (filter.showOverdueOnly && !t.isOverdue) return false;
      if (filter.showTodayOnly && !t.isDueToday) return false;
      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) && !t.description.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    result.sort((a, b) {
      switch (sort) {
        case TaskSort.priority:
          return a.priority.compareTo(b.priority);
        case TaskSort.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSort.createdDate:
          return b.createdAt.compareTo(a.createdAt);
        case TaskSort.energyLevel:
          return a.energy.compareTo(b.energy);
      }
    });

    // Pinned always first
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return result;
  }

  int get pendingCount => tasks.where((t) =>
      t.status != TaskStatus.completed.index && t.status != TaskStatus.cancelled.index).length;
  int get overdueCount => tasks.where((t) => t.isOverdue).length;
  int get completedCount => tasks.where((t) => t.status == TaskStatus.completed.index).length;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(const TasksState()) {
    _load();
  }

  void _load() {
    final box = HiveService.tasks;
    final tasks = box.values.whereType<TaskModel>().toList();
    state = state.copyWith(tasks: tasks);
  }

  Future<void> addTask(TaskModel task) async {
    await HiveService.tasks.put(task.id, task);
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  Future<void> updateTask(TaskModel task) async {
    await HiveService.tasks.put(task.id, task);
    final idx = state.tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      final updated = [...state.tasks];
      updated[idx] = task;
      state = state.copyWith(tasks: updated);
    }
  }

  Future<void> deleteTask(String id) async {
    await HiveService.tasks.delete(id);
    state = state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList());
  }

  Future<void> toggleComplete(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final newStatus = task.status == TaskStatus.completed.index
        ? TaskStatus.pending.index
        : TaskStatus.completed.index;
    final updated = task.copyWith(
      status: newStatus,
      completedAt: newStatus == TaskStatus.completed.index ? DateTime.now() : null,
    );
    await updateTask(updated);

    // Auto-create next recurring instance
    if (newStatus == TaskStatus.completed.index && task.repeat != RepeatSchedule.none.index) {
      await _createNextRecurringTask(task);
    }
  }

  Future<void> _createNextRecurringTask(TaskModel completed) async {
    if (completed.dueDate == null) return;
    Duration? delta;
    switch (completed.repeatEnum) {
      case RepeatSchedule.daily: delta = const Duration(days: 1); break;
      case RepeatSchedule.weekly: delta = const Duration(days: 7); break;
      case RepeatSchedule.monthly:
        final next = DateTime(completed.dueDate!.year, completed.dueDate!.month + 1, completed.dueDate!.day);
        delta = next.difference(completed.dueDate!);
        break;
      case RepeatSchedule.custom:
        delta = Duration(days: completed.customRepeatDays ?? 7);
        break;
      default: return;
    }
    final next = TaskModel(
      title: completed.title,
      description: completed.description,
      priority: completed.priority,
      status: TaskStatus.pending.index,
      type: completed.type,
      energy: completed.energy,
      dueDate: completed.dueDate!.add(delta),
      repeat: completed.repeat,
      customRepeatDays: completed.customRepeatDays,
      parentTaskId: completed.id,
    );
    await addTask(next);
  }

  Future<void> bulkComplete(List<String> ids) async {
    for (final id in ids) await toggleComplete(id);
  }

  Future<void> bulkDelete(List<String> ids) async {
    for (final id in ids) await deleteTask(id);
  }

  void setFilter(TaskFilter filter) => state = state.copyWith(filter: filter);
  void clearFilter() => state = state.copyWith(filter: const TaskFilter());
  void setSort(TaskSort sort) => state = state.copyWith(sort: sort);
  void setSearch(String q) => state = state.copyWith(filter: state.filter.copyWith(searchQuery: q));
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>(
  (ref) => TasksNotifier(),
);
