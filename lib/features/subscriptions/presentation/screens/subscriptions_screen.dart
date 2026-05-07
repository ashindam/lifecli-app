import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/subscription_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/bdt_input_field.dart';
import '../../../../core/widgets/empty_state.dart';

final _subProvider = StateNotifierProvider<_SubNotifier, List<SubscriptionModel>>(
  (ref) => _SubNotifier(),
);

class _SubNotifier extends StateNotifier<List<SubscriptionModel>> {
  _SubNotifier() : super([]) { _load(); }
  void _load() { state = HiveService.subscriptions.values.whereType<SubscriptionModel>().toList()..sort((a, b) => a.daysUntilRenewal.compareTo(b.daysUntilRenewal)); }
  Future<void> add(SubscriptionModel s) async { await HiveService.subscriptions.put(s.id, s); _load(); }
  Future<void> renew(String id) async {
    final s = state.firstWhere((s) => s.id == id);
    final next = DateTime(s.renewalDate.year, s.renewalDate.month + 1, s.renewalDate.day);
    await HiveService.subscriptions.put(id, s.copyWith(renewalDate: next, lastRenewedDate: DateTime.now())); _load();
  }
  Future<void> delete(String id) async { await HiveService.subscriptions.delete(id); _load(); }
}

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(_subProvider);
    final monthlyTotal = subs.where((s) => s.isActive).fold(0, (sum, s) => sum + s.amountPaisa);

    return Scaffold(
      appBar: AppBar(title: Text('Subscriptions & Bills', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: subs.isEmpty
          ? const EmptyState(emoji: '📱', title: 'No subscriptions', subtitle: 'Track mobile recharges, streaming & recurring bills')
          : Column(children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Text('📊', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Monthly recurring cost', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                    Text(CurrencyFormatter.format(monthlyTotal), style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ])),
                ]),
              ),
              Expanded(child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: subs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final s = subs[i];
                  final days = s.daysUntilRenewal;
                  final isUrgent = days <= 2;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUrgent ? AppColors.error.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(s.operator_ != null ? '📶' : '💳', style: const TextStyle(fontSize: 20)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(isUrgent ? '⚠️ Renews in $days day${days == 1 ? '' : 's'}!' : 'Renews ${DateFormat('d MMM').format(s.renewalDate)}',
                          style: GoogleFonts.inter(fontSize: 12, color: isUrgent ? AppColors.error : Colors.grey, fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(CurrencyFormatter.format(s.amountPaisa), style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                        TextButton(onPressed: () => ref.read(_subProvider.notifier).renew(s.id),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: Text('Renew ✓', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success))),
                      ]),
                    ]),
                  );
                },
              )),
            ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    DateTime renewalDate = DateTime.now().add(const Duration(days: 30));
    String? operator_;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add Subscription', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Netflix, Grameenphone)')),
            const SizedBox(height: 12),
            BdtInputField(controller: amtCtrl, label: 'Amount'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: operator_,
              decoration: const InputDecoration(labelText: 'Operator (optional)'),
              items: [null, ...AppStrings.mobileOperators].map((o) => DropdownMenuItem(value: o, child: Text(o ?? 'None'))).toList(),
              onChanged: (v) => setSt(() => operator_ = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: ctx, initialDate: renewalDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setSt(() => renewalDate = d);
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('Renewal: ${DateFormat('d MMM yyyy').format(renewalDate)}'),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.replaceAll(',', '')) ?? 0;
                if (nameCtrl.text.trim().isEmpty || amt <= 0) return;
                ref.read(_subProvider.notifier).add(SubscriptionModel(
                  name: nameCtrl.text.trim(), amountPaisa: (amt * 100).round(),
                  renewalDate: renewalDate, operator_: operator_,
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
