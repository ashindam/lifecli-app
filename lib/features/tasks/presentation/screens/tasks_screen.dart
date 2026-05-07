import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/task_model.dart';
import '../providers/tasks_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/tag_chip.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});
  @override ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  final Set<String> _selected = {};
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider);
    final notifier = ref.read(tasksProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: notifier.setSearch,
                decoration: const InputDecoration(hintText: 'Search tasks…', border: InputBorder.none),
              )
            : Text('Tasks', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          if (_selectMode) ...[
            TextButton(
              onPressed: () {
                notifier.bulkComplete(_selected.toList());
                setState(() { _selected.clear(); _selectMode = false; });
              },
              child: const Text('Complete'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                notifier.bulkDelete(_selected.toList());
                setState(() { _selected.clear(); _selectMode = false; });
              },
            ),
          ] else ...[
            IconButton(
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() { _searching = !_searching; });
                if (!_searching) { _searchCtrl.clear(); notifier.setSearch(''); }
              },
            ),
            PopupMenuButton<TaskSort>(
              icon: const Icon(Icons.sort),
              onSelected: notifier.setSort,
              itemBuilder: (_) => [
                const PopupMenuItem(value: TaskSort.priority, child: Text('By Priority')),
                const PopupMenuItem(value: TaskSort.dueDate, child: Text('By Due Date')),
                const PopupMenuItem(value: TaskSort.createdDate, child: Text('By Created')),
                const PopupMenuItem(value: TaskSort.energyLevel, child: Text('By Energy')),
              ],
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'All'), Tab(text: '⏳ Pending'), Tab(text: '🔄 Active'),
            Tab(text: '✅ Done'), Tab(text: '🔴 Overdue'),
          ],
          onTap: (i) {
            switch (i) {
              case 0: notifier.setFilter(const TaskFilter()); break;
              case 1: notifier.setFilter(TaskFilter(status: TaskStatus.pending.index)); break;
              case 2: notifier.setFilter(TaskFilter(status: TaskStatus.inProgress.index)); break;
              case 3: notifier.setFilter(TaskFilter(status: TaskStatus.completed.index)); break;
              case 4: notifier.setFilter(const TaskFilter(showOverdueOnly: true)); break;
            }
          },
        ),
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/add'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody(TasksState state, TasksNotifier notifier) {
    final tasks = state.filteredTasks;
    if (tasks.isEmpty) {
      return const EmptyState(
        emoji: '📋',
        title: 'No tasks here',
        subtitle: 'Add a task to get started. Tap + below.',
      );
    }
    return Column(
      children: [
        if (state.overdueCount > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '${state.overdueCount} overdue task${state.overdueCount == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _TaskCard(
              task: tasks[i],
              isSelected: _selected.contains(tasks[i].id),
              selectMode: _selectMode,
              onTap: () {
                if (_selectMode) {
                  setState(() {
                    if (_selected.contains(tasks[i].id)) _selected.remove(tasks[i].id);
                    else _selected.add(tasks[i].id);
                    if (_selected.isEmpty) _selectMode = false;
                  });
                } else {
                  context.push('/tasks/${tasks[i].id}');
                }
              },
              onLongPress: () => setState(() {
                _selectMode = true;
                _selected.add(tasks[i].id);
              }),
              onComplete: () => notifier.toggleComplete(tasks[i].id),
              onDelete: () => notifier.deleteTask(tasks[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isSelected;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task, required this.isSelected, required this.selectMode,
    required this.onTap, required this.onLongPress, required this.onComplete, required this.onDelete,
  });

  Color _priorityColor() {
    switch (task.priorityEnum) {
      case TaskPriority.critical: return AppColors.priorityCritical;
      case TaskPriority.high: return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low: return AppColors.priorityLow;
      case TaskPriority.someday: return AppColors.prioritySomeday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.statusEnum == TaskStatus.completed;
    return Dismissible(
      key: Key(task.id),
      background: Container(
        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (dir) => dir == DismissDirection.startToEnd ? onComplete() : onDelete(),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: _priorityColor(), width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (selectMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: AppColors.primary, size: 22,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onComplete,
                      child: Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? AppColors.success : AppColors.prioritySomeday,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: [
                    TagChip(label: task.priorityEmoji + ' ' + ['Critical','High','Medium','Low','Someday'][task.priority],
                      color: _priorityColor(), compact: true),
                    TagChip(label: task.typeEmoji + ' ' + ['Academic','Tuition','Finance','Personal','Health','Social'][task.type],
                      color: AppColors.primary, compact: true),
                    TagChip(label: task.energyEmoji, color: AppColors.accent, compact: true),
                    if (task.isOverdue) TagChip(label: '🔥 Overdue', color: AppColors.error, compact: true),
                    if (task.isDueToday) TagChip(label: '⏰ Today', color: AppColors.warning, compact: true),
                    if (task.isPinned) TagChip(label: '📌 Pinned', color: AppColors.info, compact: true),
                  ],
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 13, color: task.isOverdue ? AppColors.error : AppColors.prioritySomeday),
                      const SizedBox(width: 4),
                      Text(
                        DateHelpers.relativeDate(task.dueDate!),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: task.isOverdue ? AppColors.error : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
