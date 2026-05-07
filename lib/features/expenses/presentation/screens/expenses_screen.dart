import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/expense_model.dart';
import '../providers/expenses_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/bdt_input_field.dart';
import '../../../../core/widgets/empty_state.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesProvider);
    final notifier = ref.read(expensesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.pie_chart_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => _showBudgetSheet(context, ref)),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: notifier.previousMonth, icon: const Icon(Icons.chevron_left)),
                Text(
                  DateFormat('MMMM yyyy').format(state.selectedMonth),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(onPressed: notifier.nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          // Summary card
          _SummaryCard(state: state),
          // Category grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Text('By Category', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('See chart')),
            ]),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppStrings.expenseCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final cat = AppStrings.expenseCategories[i];
                final spent = state.byCategory[cat] ?? 0;
                final usage = state.budgetUsagePercent(cat);
                final limit = state.budgetLimitPaisa(cat);
                return _CategoryCard(
                  category: cat,
                  spent: spent,
                  limit: limit,
                  usage: usage,
                );
              },
            ),
          ),
          // Expense list
          Expanded(
            child: state.monthExpenses.isEmpty
                ? const EmptyState(emoji: '💸', title: 'No expenses yet', subtitle: 'Tap + to log an expense')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: state.monthExpenses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final exp = state.monthExpenses.reversed.toList()[i];
                      return Dismissible(
                        key: Key(exp.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => notifier.deleteExpense(exp.id),
                        child: ListTile(
                          leading: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(
                              AppStrings.expenseCategoryIcons[exp.category] ?? '📦',
                              style: const TextStyle(fontSize: 20),
                            )),
                          ),
                          title: Text(exp.category, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: exp.note.isNotEmpty
                              ? Text(exp.note, style: GoogleFonts.inter(fontSize: 12))
                              : Text(DateFormat('d MMM').format(exp.date),
                                  style: GoogleFonts.inter(fontSize: 12)),
                          trailing: Text(
                            CurrencyFormatter.format(exp.amountPaisa),
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = AppStrings.expenseCategories.first;
    DateTime date = DateTime.now();
    bool isRecurring = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Expense', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              BdtInputField(controller: amountCtrl, label: 'Amount', autofocus: true),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppStrings.expenseCategories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Row(children: [
                    Text(AppStrings.expenseCategoryIcons[c] ?? '📦'),
                    const SizedBox(width: 8), Text(c),
                  ]),
                )).toList(),
                onChanged: (v) => setSt(() => category = v ?? category),
              ),
              const SizedBox(height: 14),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx, initialDate: date,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setSt(() => date = d);
                  },
                  child: Text(DateFormat('d MMM yyyy').format(date)),
                ),
                const Spacer(),
                const Text('Recurring'),
                Switch(value: isRecurring, onChanged: (v) => setSt(() => isRecurring = v), activeColor: AppColors.primary),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    if (amt <= 0) return;
                    ref.read(expensesProvider.notifier).addExpense(ExpenseModel(
                      amountPaisa: (amt * 100).round(),
                      category: category,
                      note: noteCtrl.text.trim(),
                      date: date,
                      isRecurring: isRecurring,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4,
        expand: false,
        builder: (ctx, ctrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Monthly Budgets', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  itemCount: AppStrings.expenseCategories.length,
                  itemBuilder: (ctx, i) {
                    final cat = AppStrings.expenseCategories[i];
                    final ctrl2 = TextEditingController();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Text(AppStrings.expenseCategoryIcons[cat] ?? '📦', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(cat, style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
                        SizedBox(
                          width: 120,
                          child: BdtInputField(controller: ctrl2, label: 'Limit',
                            onChanged: (v) {
                              final amt = double.tryParse(v.replaceAll(',', '')) ?? 0;
                              if (amt > 0) ref.read(expensesProvider.notifier).setBudget(cat, (amt * 100).round());
                            }),
                        ),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExpensesState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final spent = state.monthTotalPaisa;
    final budget = state.totalBudgetPaisa;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final overBudget = budget > 0 && spent > budget;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: overBudget
              ? [AppColors.error, AppColors.error.withOpacity(0.7)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(CurrencyFormatter.format(spent),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              if (budget > 0) ...[
                Text(' of ', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
                Text(CurrencyFormatter.format(budget),
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          if (budget > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation(overBudget ? Colors.yellow : Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              overBudget ? '🚨 Over budget!' : '${(progress * 100).round()}% of budget used',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int spent;
  final int limit;
  final double usage;

  const _CategoryCard({required this.category, required this.spent, required this.limit, required this.usage});

  @override
  Widget build(BuildContext context) {
    final isOver = usage >= 1.0;
    final isWarning = usage >= 0.8 && !isOver;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOver ? AppColors.errorContainer : isWarning ? AppColors.warningContainer : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOver ? AppColors.error.withOpacity(0.3) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.expenseCategoryIcons[category] ?? '📦', style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(category, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(CurrencyFormatter.shortFormat(spent),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
              color: isOver ? AppColors.error : null)),
          if (limit > 0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: usage,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(isOver ? AppColors.error : isWarning ? AppColors.warning : AppColors.success),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }
}
