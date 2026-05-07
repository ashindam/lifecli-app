import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/bill_split_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/bdt_input_field.dart';

final _billProvider = StateNotifierProvider<_BillNotifier, List<BillSplitModel>>(
  (ref) => _BillNotifier(),
);

class _BillNotifier extends StateNotifier<List<BillSplitModel>> {
  _BillNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.billSplits.values.whereType<BillSplitModel>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  Future<void> add(BillSplitModel b) async { await HiveService.billSplits.put(b.id, b); _load(); }
  Future<void> delete(String id) async { await HiveService.billSplits.delete(id); _load(); }
  Future<void> togglePaid(String billId, int participantIndex) async {
    final b = state.firstWhere((b) => b.id == billId);
    final updated = b.participants.asMap().entries.map((e) {
      if (e.key == participantIndex) {
        return e.value.copyWith(hasPaid: !e.value.hasPaid);
      }
      return e.value;
    }).toList();
    final copy = b.copyWith(participants: updated);
    await HiveService.billSplits.put(billId, copy);
    _load();
  }
}

class BillSplitterScreen extends ConsumerWidget {
  const BillSplitterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(_billProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Bill Splitter', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: bills.isEmpty
          ? const EmptyState(emoji: '🧾', title: 'No bills yet', subtitle: 'Split restaurant bills, trips and group expenses')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: bills.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _BillCard(bill: bills[i], ref: ref),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('New Split'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final List<String> names = [];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('New Bill Split', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Description (e.g. Dinner at Kacchi)')),
            const SizedBox(height: 12),
            BdtInputField(controller: totalCtrl, label: 'Total Amount'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Add person', hintText: 'Name'))),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setSt(() { names.add(nameCtrl.text.trim()); nameCtrl.clear(); });
                  }
                },
                child: const Text('Add'),
              ),
            ]),
            if (names.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: names.map((n) => Chip(
                label: Text(n),
                onDeleted: () => setSt(() => names.remove(n)),
              )).toList()),
            ],
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final total = double.tryParse(totalCtrl.text.replaceAll(',', '')) ?? 0;
                if (titleCtrl.text.trim().isEmpty || total <= 0 || names.length < 2) return;
                final totalAmountPaisa = (total * 100).round();
                final share = (totalAmountPaisa / names.length).round();
                final bill = BillSplitModel(title: titleCtrl.text.trim(), totalAmountPaisa: totalAmountPaisa);
                bill.participants = names.map((n) => ParticipantModel(name: n, amountPaisa: share)).toList();
                ref.read(_billProvider.notifier).add(bill);
                Navigator.pop(ctx);
              },
              child: const Text('Split Bill'),
            )),
            const SizedBox(height: 8),
            Text('Need at least 2 people', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      ),
    );
  }
}

class _BillCard extends ConsumerWidget {
  final BillSplitModel bill;
  final WidgetRef ref;
  const _BillCard({required this.bill, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final participants = bill.participants;
    final paidCount = participants.where((p) => p.hasPaid).length;
    final allPaid = paidCount == participants.length && participants.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: allPaid ? AppColors.success.withOpacity(0.3) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bill.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Total: ${CurrencyFormatter.format(bill.totalAmountPaisa)} • ${participants.length} people',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ])),
            if (allPaid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(20)),
                child: Text('✓ Settled', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
              ),
            PopupMenuButton(
              itemBuilder: (_) => [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
              onSelected: (v) { if (v == 'delete') ref.read(_billProvider.notifier).delete(bill.id); },
            ),
          ]),
        ),
        LinearProgressIndicator(
          value: participants.isEmpty ? 0 : paidCount / participants.length,
          backgroundColor: AppColors.primaryContainer,
          valueColor: const AlwaysStoppedAnimation(AppColors.success),
          minHeight: 3,
        ),
        ...participants.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: p.hasPaid ? AppColors.successContainer : AppColors.primaryContainer,
              child: Text(p.name[0].toUpperCase(), style: TextStyle(fontSize: 12, color: p.hasPaid ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w700)),
            ),
            title: Text(p.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(CurrencyFormatter.format(p.amountPaisa), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            trailing: GestureDetector(
              onTap: () => ref.read(_billProvider.notifier).togglePaid(bill.id, i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p.hasPaid ? AppColors.successContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.hasPaid ? AppColors.success : Colors.grey.shade300),
                ),
                child: Text(p.hasPaid ? 'Paid ✓' : 'Mark paid',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: p.hasPaid ? AppColors.success : Colors.grey)),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
      ]),
    );
  }
}
