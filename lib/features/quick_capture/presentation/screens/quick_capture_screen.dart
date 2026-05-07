import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/inbox_provider.dart';
import '../../data/inbox_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';

class QuickCaptureScreen extends ConsumerStatefulWidget {
  const QuickCaptureScreen({super.key});
  @override ConsumerState<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends ConsumerState<QuickCaptureScreen> {
  final _ctrl = TextEditingController();
  final _speech = SpeechToText();
  bool _listening = false;

  Future<void> _toggleListen() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize();
    if (available) {
      setState(() => _listening = true);
      await _speech.listen(onResult: (r) {
        setState(() => _ctrl.text = r.recognizedWords);
      });
    }
  }

  void _capture() {
    if (_ctrl.text.trim().isEmpty) return;
    ref.read(inboxProvider.notifier).addItem(_ctrl.text.trim());
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captured! ✅')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Capture', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          if (state.unprocessedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('${state.unprocessedCount} to process'),
                backgroundColor: AppColors.warning.withOpacity(0.15),
                side: BorderSide.none,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                TextField(
                  controller: _ctrl, maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Capture anything… task, idea, reminder, expense…',
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(_listening ? Icons.mic : Icons.mic_none, color: _listening ? AppColors.error : null),
                      onPressed: _toggleListen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _capture,
                    icon: const Icon(Icons.add),
                    label: const Text('Capture'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Text('Inbox', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (state.unprocessedCount > 0)
                TextButton(onPressed: () {}, child: const Text('Process all')),
            ]),
          ),
          Expanded(
            child: state.unprocessed.isEmpty
                ? const EmptyState(emoji: '📥', title: 'Inbox is clear!', subtitle: 'Capture anything above — organize later')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: state.unprocessed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = state.unprocessed[i];
                      return _InboxCard(
                        item: item,
                        onProcess: (type) => ref.read(inboxProvider.notifier).processItem(item.id, type),
                        onDiscard: () => ref.read(inboxProvider.notifier).discard(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InboxCard extends StatefulWidget {
  final InboxItemModel item;
  final ValueChanged<String> onProcess;
  final VoidCallback onDiscard;
  const _InboxCard({required this.item, required this.onProcess, required this.onDiscard});
  @override State<_InboxCard> createState() => _InboxCardState();
}

class _InboxCardState extends State<_InboxCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Text('📥', style: TextStyle(fontSize: 20)),
            title: Text(widget.item.content, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
            subtitle: Text(DateHelpers.relativeDate(widget.item.createdAt),
              style: GoogleFonts.inter(fontSize: 11)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Convert to:', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _ProcessChip('📋 Task', AppColors.primary, () => widget.onProcess('task')),
                    _ProcessChip('📝 Note', AppColors.info, () => widget.onProcess('note')),
                    _ProcessChip('💸 Expense', AppColors.success, () => widget.onProcess('expense')),
                    _ProcessChip('⏰ Reminder', AppColors.warning, () => widget.onProcess('reminder')),
                    _ProcessChip('🗑️ Discard', AppColors.error, widget.onDiscard),
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProcessChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ProcessChip(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ),
  );
}
