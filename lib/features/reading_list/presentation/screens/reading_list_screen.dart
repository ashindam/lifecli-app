import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/reading_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

final _readingProvider = StateNotifierProvider<_ReadingNotifier, List<ReadingItemModel>>(
  (ref) => _ReadingNotifier(),
);

class _ReadingNotifier extends StateNotifier<List<ReadingItemModel>> {
  _ReadingNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.reading.values.whereType<ReadingItemModel>().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  Future<void> add(ReadingItemModel r) async { await HiveService.reading.put(r.id, r); _load(); }
  Future<void> delete(String id) async { await HiveService.reading.delete(id); _load(); }
  Future<void> updateStatus(String id, ReadingStatus status) async {
    final r = state.firstWhere((r) => r.id == id);
    await HiveService.reading.put(id, r.copyWith(status: status.index));
    _load();
  }
}

class ReadingListScreen extends ConsumerStatefulWidget {
  const ReadingListScreen({super.key});
  @override ConsumerState<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends ConsumerState<ReadingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(_readingProvider);
    final unread = all.where((r) => r.statusEnum == ReadingStatus.unread).toList();
    final inProgress = all.where((r) => r.statusEnum == ReadingStatus.inProgress).toList();
    final done = all.where((r) => r.statusEnum == ReadingStatus.done).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading List', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(text: '📚 Unread (${unread.length})'),
            Tab(text: '📖 Reading (${inProgress.length})'),
            Tab(text: '✅ Done (${done.length})'),
          ],
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ReadingListView(items: all, ref: ref),
          _ReadingListView(items: unread, ref: ref),
          _ReadingListView(items: inProgress, ref: ref),
          _ReadingListView(items: done, ref: ref),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add), label: const Text('Add Item'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    int selectedType = ReadingType.book.index;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add to Reading List', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
            const SizedBox(height: 12),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL / Link (optional)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                DropdownMenuItem(value: ReadingType.youtube.index, child: const Text('▶️ YouTube')),
                DropdownMenuItem(value: ReadingType.pdf.index, child: const Text('📄 PDF')),
                DropdownMenuItem(value: ReadingType.book.index, child: const Text('📗 Book')),
                DropdownMenuItem(value: ReadingType.article.index, child: const Text('🔗 Article')),
              ],
              onChanged: (v) => setSt(() => selectedType = v ?? ReadingType.book.index),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                ref.read(_readingProvider.notifier).add(ReadingItemModel(
                  title: titleCtrl.text.trim(),
                  url: urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim(),
                  type: selectedType,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )),
          ]),
        ),
      ),
    );
  }
}

class _ReadingListView extends StatelessWidget {
  final List<ReadingItemModel> items;
  final WidgetRef ref;
  const _ReadingListView({required this.items, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyState(emoji: '📚', title: 'Nothing here', subtitle: 'Add books and articles to track your reading');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _ReadingCard(item: items[i], ref: ref),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final ReadingItemModel item;
  final WidgetRef ref;
  const _ReadingCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDone = item.statusEnum == ReadingStatus.done;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDone
            ? AppColors.success.withOpacity(0.3)
            : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(item.typeEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              decoration: isDone ? TextDecoration.lineThrough : null,
            )),
            Text(item.typeLabel, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ])),
          PopupMenuButton(
            iconSize: 18,
            itemBuilder: (_) => [
              if (item.statusEnum != ReadingStatus.unread)
                const PopupMenuItem(value: 'unread', child: Text('📚 Mark Unread')),
              if (item.statusEnum != ReadingStatus.inProgress)
                const PopupMenuItem(value: 'reading', child: Text('📖 Mark Reading')),
              if (item.statusEnum != ReadingStatus.done)
                const PopupMenuItem(value: 'done', child: Text('✅ Mark Done')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            onSelected: (v) {
              if (v == 'unread') ref.read(_readingProvider.notifier).updateStatus(item.id, ReadingStatus.unread);
              if (v == 'reading') ref.read(_readingProvider.notifier).updateStatus(item.id, ReadingStatus.inProgress);
              if (v == 'done') ref.read(_readingProvider.notifier).updateStatus(item.id, ReadingStatus.done);
              if (v == 'delete') ref.read(_readingProvider.notifier).delete(item.id);
            },
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _StatusBadge(item.statusEnum),
          const Spacer(),
          Text(item.statusEmoji, style: const TextStyle(fontSize: 16)),
        ]),
        if (item.url != null && item.url!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(item.url!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
            overflow: TextOverflow.ellipsis),
        ],
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReadingStatus status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      ReadingStatus.unread => ('Unread', Colors.grey[700]!, const Color(0xFFF1F5F9)),
      ReadingStatus.inProgress => ('Reading', AppColors.primary, AppColors.primaryContainer),
      ReadingStatus.done => ('Done', AppColors.success, AppColors.successContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
