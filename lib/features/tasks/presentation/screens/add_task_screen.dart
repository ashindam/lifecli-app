import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/task_model.dart';
import '../providers/tasks_provider.dart';
import '../../../../core/constants/app_colors.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? existing;
  const AddTaskScreen({super.key, this.existing});
  @override ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _priority = 2;
  int _type = 3;
  int _energy = 2;
  int _status = 0;
  DateTime? _dueDate;
  int _repeat = 0;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _priority = t.priority; _type = t.type; _energy = t.energy;
      _status = t.status; _dueDate = t.dueDate; _repeat = t.repeat; _isPinned = t.isPinned;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(tasksProvider.notifier);
    if (widget.existing != null) {
      await notifier.updateTask(widget.existing!.copyWith(
        title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        priority: _priority, type: _type, energy: _energy, status: _status,
        dueDate: _dueDate, repeat: _repeat, isPinned: _isPinned,
      ));
    } else {
      await notifier.addTask(TaskModel(
        title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        priority: _priority, type: _type, energy: _energy, status: _status,
        dueDate: _dueDate, repeat: _repeat, isPinned: _isPinned,
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Add',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl, autofocus: true,
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
              decoration: const InputDecoration(labelText: 'Task title', hintText: 'What needs to be done?'),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl, maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Add details…'),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Priority'),
            const SizedBox(height: 8),
            _SegmentRow(
              items: const [('🔴 Critical', 0), ('🟠 High', 1), ('🟡 Medium', 2), ('🟢 Low', 3), ('⚪ Someday', 4)],
              selected: _priority, onChanged: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Type'),
            const SizedBox(height: 8),
            _SegmentRow(
              items: const [('📚 Academic', 0), ('💼 Tuition', 1), ('💸 Finance', 2), ('🏠 Personal', 3), ('🏃 Health', 4), ('🤝 Social', 5)],
              selected: _type, onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Energy Level'),
            const SizedBox(height: 8),
            _SegmentRow(
              items: const [('⚡ High Focus', 0), ('🧠 Deep Work', 1), ('😌 Easy', 2), ('📞 Errands', 3)],
              selected: _energy, onChanged: (v) => setState(() => _energy = v),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Status'),
            const SizedBox(height: 8),
            _SegmentRow(
              items: const [('🔵 Pending', 0), ('🔄 In Progress', 1), ('⏸ On Hold', 2)],
              selected: _status, onChanged: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Due Date'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(_dueDate == null ? 'Set due date' :
                '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
            ),
            if (_dueDate != null) TextButton(
              onPressed: () => setState(() => _dueDate = null),
              child: const Text('Clear date', style: TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Repeat'),
            const SizedBox(height: 8),
            _SegmentRow(
              items: const [('None', 0), ('Daily', 1), ('Weekly', 2), ('Monthly', 3)],
              selected: _repeat, onChanged: (v) => setState(() => _repeat = v),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: _isPinned, onChanged: (v) => setState(() => _isPinned = v),
              title: const Text('📌 Pin this task'),
              subtitle: const Text('Pinned tasks appear at the top'),
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)));
}

class _SegmentRow extends StatelessWidget {
  final List<(String, int)> items;
  final int selected;
  final ValueChanged<int> onChanged;
  const _SegmentRow({required this.items, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: items.map((item) {
      final isSelected = item.$2 == selected;
      return GestureDetector(
        onTap: () => onChanged(item.$2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
          ),
          child: Text(item.$1, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          )),
        ),
      );
    }).toList(),
  );
}
