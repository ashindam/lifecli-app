import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/notice_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

final _noticeProvider = StateNotifierProvider<_NoticeNotifier, List<NoticeModel>>(
  (ref) => _NoticeNotifier(),
);

class _NoticeNotifier extends StateNotifier<List<NoticeModel>> {
  _NoticeNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.notices.values.whereType<NoticeModel>().where((n) => !n.isArchived).toList()
      ..sort((a, b) { if (a.isPinned && !b.isPinned) return -1; if (!a.isPinned && b.isPinned) return 1; return b.date.compareTo(a.date); });
  }
  Future<void> add(NoticeModel n) async { await HiveService.notices.put(n.id, n); _load(); }
  Future<void> togglePin(String id) async {
    final n = state.firstWhere((n) => n.id == id);
    await HiveService.notices.put(id, n.copyWith(isPinned: !n.isPinned)); _load();
  }
  Future<void> archive(String id) async {
    final n = state.firstWhere((n) => n.id == id);
    await HiveService.notices.put(id, n.copyWith(isArchived: true)); _load();
  }
}

class NoticeBoardScreen extends ConsumerWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(_noticeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Notice Board', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: notices.isEmpty
          ? const EmptyState(emoji: '📋', title: 'No notices', subtitle: 'Save important university notices here')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final n = notices[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isPinned ? AppColors.warningContainer : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: n.isPinned ? AppColors.warning.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(n.sourceEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(6)),
                        child: Text(n.sourceLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                      const Spacer(),
                      if (n.isPinned) const Icon(Icons.push_pin, size: 16, color: AppColors.warning),
                      PopupMenuButton(
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'pin', child: Text(n.isPinned ? 'Unpin' : 'Pin')),
                          const PopupMenuItem(value: 'archive', child: Text('Archive')),
                        ],
                        onSelected: (v) {
                          if (v == 'pin') ref.read(_noticeProvider.notifier).togglePin(n.id);
                          if (v == 'archive') ref.read(_noticeProvider.notifier).archive(n.id);
                        },
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(n.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(n.body, style: GoogleFonts.inter(fontSize: 13), maxLines: 4, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(DateHelpers.relativeDate(n.date), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                  ]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Notice'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    int source = 2;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add Notice', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Details')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: source,
              decoration: const InputDecoration(labelText: 'Source'),
              items: [0, 1, 2, 3].map((i) => DropdownMenuItem(value: i, child: Text(['Department', 'Hall', 'University', 'Teacher'][i]))).toList(),
              onChanged: (v) => setSt(() => source = v ?? 2),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                ref.read(_noticeProvider.notifier).add(NoticeModel(title: titleCtrl.text.trim(), body: bodyCtrl.text.trim(), sourceTag: source));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )),
          ]),
        ),
      ),
    );
  }
}
