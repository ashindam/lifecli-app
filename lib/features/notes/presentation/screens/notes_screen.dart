import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/note_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

final _notesProvider = StateNotifierProvider<_NotesNotifier, List<NoteModel>>(
  (ref) => _NotesNotifier(),
);

class _NotesNotifier extends StateNotifier<List<NoteModel>> {
  _NotesNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.notes.values.whereType<NoteModel>().toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }
  Future<void> add(NoteModel note) async {
    await HiveService.notes.put(note.id, note); _load();
  }
  Future<void> update(NoteModel note) async {
    await HiveService.notes.put(note.id, note); _load();
  }
  Future<void> delete(String id) async {
    await HiveService.notes.delete(id); _load();
  }
  Future<void> togglePin(String id) async {
    final n = state.firstWhere((n) => n.id == id);
    await update(n.copyWith(isPinned: !n.isPinned));
  }
}

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  @override ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _search = '';
  int? _colorFilter;

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(_notesProvider);
    var filtered = notes.where((n) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return n.title.toLowerCase().contains(q) || n.body.toLowerCase().contains(q);
      }
      if (_colorFilter != null) return n.colorLabel == _colorFilter;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search notes…', prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Color filters
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: AppColors.noteLabels.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                if (i == 0) return GestureDetector(
                  onTap: () => setState(() => _colorFilter = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _colorFilter == null ? AppColors.primary : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('All', style: GoogleFonts.inter(
                      color: _colorFilter == null ? Colors.white : AppColors.primary,
                      fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ),
                );
                final idx = i - 1;
                return GestureDetector(
                  onTap: () => setState(() => _colorFilter = _colorFilter == idx ? null : idx),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.noteLabels[idx],
                      shape: BoxShape.circle,
                      border: _colorFilter == idx ? Border.all(color: Colors.black38, width: 3) : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(emoji: '📝', title: 'No notes yet', subtitle: 'Capture your thoughts, formulas, and ideas')
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _NoteCard(
                      note: filtered[i],
                      onPin: () => ref.read(_notesProvider.notifier).togglePin(filtered[i].id),
                      onDelete: () => ref.read(_notesProvider.notifier).delete(filtered[i].id),
                      onTap: () => _openNote(ctx, filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNote(context, null),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _openNote(BuildContext ctx, NoteModel? note) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _NoteEditorScreen(existing: note, notifier: ref.read(_notesProvider.notifier)),
    ));
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onPin, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = note.colorLabel >= 0 && note.colorLabel < AppColors.noteLabels.length
        ? AppColors.noteLabels[note.colorLabel] : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const Spacer(),
              if (note.isPinned) const Icon(Icons.push_pin, size: 14, color: Colors.grey),
              GestureDetector(onTap: onPin, child: const Icon(Icons.more_vert, size: 18, color: Colors.grey)),
            ]),
            const SizedBox(height: 8),
            if (note.title.isNotEmpty)
              Text(note.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(note.body, maxLines: 5, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            const Spacer(),
            Text(DateHelpers.formatShortDate(note.updatedAt),
              style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _NoteEditorScreen extends StatefulWidget {
  final NoteModel? existing;
  final _NotesNotifier notifier;
  const _NoteEditorScreen({this.existing, required this.notifier});
  @override State<_NoteEditorScreen> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  int _colorLabel = 0;
  bool _isPinned = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existing?.body ?? '');
    _colorLabel = widget.existing?.colorLabel ?? 0;
    _isPinned = widget.existing?.isPinned ?? false;
    _tags = List.from(widget.existing?.tags ?? []);
  }

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty && _bodyCtrl.text.trim().isEmpty) return;
    if (widget.existing != null) {
      await widget.notifier.update(widget.existing!.copyWith(
        title: _titleCtrl.text.trim(), body: _bodyCtrl.text.trim(),
        colorLabel: _colorLabel, isPinned: _isPinned, tags: _tags,
      ));
    } else {
      await widget.notifier.add(NoteModel(
        title: _titleCtrl.text.trim(), body: _bodyCtrl.text.trim(),
        colorLabel: _colorLabel, isPinned: _isPinned, tags: _tags,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned)),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...AppColors.noteLabels.asMap().entries.map((e) => GestureDetector(
                  onTap: () => setState(() => _colorLabel = e.key),
                  child: Container(
                    width: 24, height: 24, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: e.value, shape: BoxShape.circle,
                      border: _colorLabel == e.key ? Border.all(color: Colors.black38, width: 2) : null,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _bodyCtrl, maxLines: null, expands: true,
                decoration: const InputDecoration(hintText: 'Start typing…', border: InputBorder.none),
                style: GoogleFonts.inter(fontSize: 16, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
