import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/finance_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/bdt_input_field.dart';
import '../../../../core/widgets/empty_state.dart';

final _financeProvider = StateNotifierProvider<_FinanceNotifier, List<FinanceModel>>(
  (ref) => _FinanceNotifier(),
);

class _FinanceNotifier extends StateNotifier<List<FinanceModel>> {
  _FinanceNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.finance.values.whereType<FinanceModel>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  Future<void> add(FinanceModel r) async { await HiveService.finance.put(r.id, r); _load(); }
  Future<void> settle(String id) async {
    final r = state.firstWhere((r) => r.id == id);
    final updated = r.copyWith(isSettled: true, settledDate: DateTime.now());
    await HiveService.finance.put(id, updated); _load();
  }
  Future<void> delete(String id) async { await HiveService.finance.delete(id); _load(); }
}

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});
  @override ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(_financeProvider);
    final active = records.where((r) => !r.isSettled).toList();
    final loans = active.where((r) => r.typeEnum == FinanceType.loan).toList();
    final borrows = active.where((r) => r.typeEnum == FinanceType.borrow).toList();
    final totalLoaned = loans.fold(0, (s, r) => s + r.amountPaisa);
    final totalBorrowed = borrows.fold(0, (s, r) => s + r.amountPaisa);
    final net = totalLoaned - totalBorrowed;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Finance', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: '💰 Loans (I Lent)'), Tab(text: '💸 Borrows (I Owe)')]),
      ),
      body: Column(
        children: [
          // Net balance card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: net >= 0 ? AppColors.successContainer : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: net >= 0 ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text(net >= 0 ? 'People owe you' : 'You owe people',
                style: GoogleFonts.inter(fontSize: 13, color: net >= 0 ? AppColors.success : AppColors.error)),
              const SizedBox(height: 4),
              Text(CurrencyFormatter.format(net.abs()),
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800,
                  color: net >= 0 ? AppColors.success : AppColors.error)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📤 Lent: ${CurrencyFormatter.format(totalLoaned)}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.success)),
                const SizedBox(width: 20),
                Text('📥 Owe: ${CurrencyFormatter.format(totalBorrowed)}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.error)),
              ]),
            ]),
          ),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              _RecordList(records: loans, onSettle: (id) => ref.read(_financeProvider.notifier).settle(id),
                onDelete: (id) => ref.read(_financeProvider.notifier).delete(id)),
              _RecordList(records: borrows, onSettle: (id) => ref.read(_financeProvider.notifier).settle(id),
                onDelete: (id) => ref.read(_financeProvider.notifier).delete(id)),
            ]),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext ctx, WidgetRef ref, FinanceType type) {
    final amtCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime? dueDate;

    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(type == FinanceType.loan ? 'I Lent Money' : 'I Borrowed Money',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            BdtInputField(controller: amtCtrl, label: 'Amount', autofocus: true),
            const SizedBox(height: 14),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Name')),
            const SizedBox(height: 14),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: ctx, initialDate: DateTime.now(),
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setSt(() => dueDate = d);
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(dueDate == null ? 'Set due date (optional)' : DateHelpers.formatDate(dueDate!)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final amt = double.tryParse(amtCtrl.text.replaceAll(',', '')) ?? 0;
                  if (amt <= 0 || nameCtrl.text.trim().isEmpty) return;
                  ref.read(_financeProvider.notifier).add(FinanceModel(
                    type: type.index, contactName: nameCtrl.text.trim(),
                    amountPaisa: (amt * 100).round(), note: noteCtrl.text.trim(), dueDate: dueDate,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  final List<FinanceModel> records;
  final ValueChanged<String> onSettle;
  final ValueChanged<String> onDelete;
  const _RecordList({required this.records, required this.onSettle, required this.onDelete});

  @override
  Widget build(BuildContext context) => records.isEmpty
      ? const EmptyState(emoji: '🤝', title: 'No records', subtitle: 'Tap + to add a loan or borrow record')
      : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final r = records[i];
            return Dismissible(
              key: Key(r.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                color: AppColors.success,
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check, color: Colors.white),
                  Text('Settled', style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
              onDismissed: (_) => onSettle(r.id),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: r.typeEnum == FinanceType.loan ? AppColors.successContainer : AppColors.errorContainer, shape: BoxShape.circle),
                    child: Center(child: Text(r.typeEnum == FinanceType.loan ? '📤' : '📥', style: const TextStyle(fontSize: 20)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.contactName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (r.note.isNotEmpty) Text(r.note, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    if (r.dueDate != null) Text('Due: ${DateHelpers.countdownText(r.dueDate!)}',
                      style: GoogleFonts.inter(fontSize: 12, color: r.dueDate!.isBefore(DateTime.now()) ? AppColors.error : Colors.grey)),
                  ])),
                  Text(CurrencyFormatter.format(r.amountPaisa),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800,
                      color: r.typeEnum == FinanceType.loan ? AppColors.success : AppColors.error)),
                ]),
              ),
            );
          },
        );
}
