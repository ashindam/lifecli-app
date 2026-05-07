import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/allowance_model.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/bdt_input_field.dart';

final _allowanceProvider = StateNotifierProvider<_AllowanceNotifier, AllowanceModel?>(
  (ref) => _AllowanceNotifier(),
);

class _AllowanceNotifier extends StateNotifier<AllowanceModel?> {
  _AllowanceNotifier() : super(null) { _load(); }
  void _load() { state = HiveService.allowance.get('current') as AllowanceModel?; }
  Future<void> set(AllowanceModel model) async {
    await HiveService.allowance.put('current', model); state = model;
  }
}

class AllowanceScreen extends ConsumerWidget {
  const AllowanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowance = ref.watch(_allowanceProvider);
    final expState = ref.watch(expensesProvider);
    final now = DateTime.now();
    final daysLeft = DateHelpers.daysLeftInMonth();
    final monthSpent = expState.monthTotalPaisa;

    int remaining = 0;
    double safePerDay = 0;
    bool isOverspending = false;

    if (allowance != null) {
      remaining = allowance.monthlyAmountPaisa - allowance.savingsAmountPaisa - monthSpent;
      safePerDay = daysLeft > 0 ? remaining / daysLeft : 0;
      // Check pace: if spending rate > allowance rate
      final elapsed = now.day;
      final expected = allowance.monthlyAmountPaisa * elapsed / 30;
      isOverspending = monthSpent > expected * 1.4;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Allowance', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (allowance == null)
            _SetupCard(onSet: () => _showSetupSheet(context, ref))
          else ...[
            _HeroCard(
              remaining: remaining,
              daysLeft: daysLeft,
              safePerDay: safePerDay,
              isOverspending: isOverspending,
              onEdit: () => _showSetupSheet(context, ref),
            ),
            const SizedBox(height: 20),
            _StatsRow(allowance: allowance, spent: monthSpent),
            if (allowance.savingsAmountPaisa > 0) ...[
              const SizedBox(height: 20),
              _SavingsCard(savings: allowance.savingsAmountPaisa),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Budget Progress', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: allowance.monthlyAmountPaisa > 0 ? (monthSpent / allowance.monthlyAmountPaisa).clamp(0, 1) : 0,
                  backgroundColor: Colors.white60,
                  valueColor: AlwaysStoppedAnimation(remaining < 0 ? AppColors.error : AppColors.success),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${CurrencyFormatter.format(monthSpent)} spent of ${CurrencyFormatter.format(allowance.monthlyAmountPaisa)}',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  void _showSetupSheet(BuildContext context, WidgetRef ref) {
    final amtCtrl = TextEditingController();
    final savingsCtrl = TextEditingController();
    int receivedDay = 1;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Set Monthly Allowance', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            BdtInputField(controller: amtCtrl, label: 'Monthly Allowance', autofocus: true),
            const SizedBox(height: 14),
            BdtInputField(controller: savingsCtrl, label: 'Auto-reserve Savings (optional)'),
            const SizedBox(height: 14),
            Row(children: [
              Text('Received on day:', style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(width: 12),
              Expanded(child: Slider(value: receivedDay.toDouble(), min: 1, max: 31, divisions: 30,
                label: receivedDay.toString(), onChanged: (v) => setSt(() => receivedDay = v.round()),
                activeColor: AppColors.primary)),
              Text('$receivedDay', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.replaceAll(',', '')) ?? 0;
                if (amt <= 0) return;
                final savings = double.tryParse(savingsCtrl.text.replaceAll(',', '')) ?? 0;
                ref.read(_allowanceProvider.notifier).set(AllowanceModel(
                  monthlyAmountPaisa: (amt * 100).round(),
                  receivedDate: receivedDay,
                  savingsAmountPaisa: (savings * 100).round(),
                  month: DateFormat('yyyy-MM').format(DateTime.now()),
                ));
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

class _SetupCard extends StatelessWidget {
  final VoidCallback onSet;
  const _SetupCard({required this.onSet});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        const Text('💰', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text('Set your monthly allowance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Track how much you have left each day', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        FilledButton(onPressed: onSet, child: const Text('Set Allowance')),
      ]),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  final int remaining;
  final int daysLeft;
  final double safePerDay;
  final bool isOverspending;
  final VoidCallback onEdit;
  const _HeroCard({required this.remaining, required this.daysLeft, required this.safePerDay, required this.isOverspending, required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isOverspending ? [AppColors.error, AppColors.error.withOpacity(0.7)] : [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(children: [
      Row(children: [
        Expanded(child: Text('Remaining', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14))),
        IconButton(icon: const Icon(Icons.edit, color: Colors.white60, size: 18), onPressed: onEdit),
      ]),
      Text(CurrencyFormatter.format(remaining.abs()),
        style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
      if (isOverspending)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: Text('⚠️ Spending 40% faster than pace!', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [
          Text('$daysLeft', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('days left', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
        ]),
        Container(width: 1, height: 40, color: Colors.white30),
        Column(children: [
          Text(CurrencyFormatter.formatTaka(safePerDay),
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('safe/day', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
        ]),
      ]),
    ]),
  );
}

class _StatsRow extends StatelessWidget {
  final AllowanceModel allowance;
  final int spent;
  const _StatsRow({required this.allowance, required this.spent});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _StatBox('Total', CurrencyFormatter.format(allowance.monthlyAmountPaisa), AppColors.primary)),
    const SizedBox(width: 10),
    Expanded(child: _StatBox('Spent', CurrencyFormatter.format(spent), AppColors.error)),
    const SizedBox(width: 10),
    Expanded(child: _StatBox('Savings', CurrencyFormatter.format(allowance.savingsAmountPaisa), AppColors.success)),
  ]);
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
    ]),
  );
}

class _SavingsCard extends StatelessWidget {
  final int savings;
  const _SavingsCard({required this.savings});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.success.withOpacity(0.3))),
    child: Row(children: [
      const Text('💎', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Auto-saving this month', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(CurrencyFormatter.format(savings), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.success)),
      ])),
    ]),
  );
}
