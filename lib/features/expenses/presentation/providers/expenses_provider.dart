import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/expense_model.dart';
import '../../../../core/services/hive_service.dart';

class ExpensesState {
  final List<ExpenseModel> expenses;
  final List<BudgetModel> budgets;
  final DateTime selectedMonth;

  const ExpensesState({
    this.expenses = const [],
    this.budgets = const [],
    DateTime? selectedMonth,
  }) : selectedMonth = selectedMonth ?? const _Now();

  ExpensesState copyWith({
    List<ExpenseModel>? expenses,
    List<BudgetModel>? budgets,
    DateTime? selectedMonth,
  }) => ExpensesState(
    expenses: expenses ?? this.expenses,
    budgets: budgets ?? this.budgets,
    selectedMonth: selectedMonth ?? this.selectedMonth,
  );

  List<ExpenseModel> get monthExpenses => expenses.where((e) =>
      e.date.year == selectedMonth.year && e.date.month == selectedMonth.month).toList();

  int get monthTotalPaisa => monthExpenses.fold(0, (sum, e) => sum + e.amountPaisa);

  Map<String, int> get byCategory {
    final map = <String, int>{};
    for (final e in monthExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amountPaisa;
    }
    return map;
  }

  double budgetUsagePercent(String category) {
    final budget = budgets.firstWhere((b) => b.category == category,
        orElse: () => BudgetModel(category: category, monthlyLimitPaisa: 0));
    if (budget.monthlyLimitPaisa == 0) return 0;
    final spent = byCategory[category] ?? 0;
    return (spent / budget.monthlyLimitPaisa).clamp(0, 1);
  }

  int budgetLimitPaisa(String category) {
    final b = budgets.firstWhere((b) => b.category == category,
        orElse: () => BudgetModel(category: category, monthlyLimitPaisa: 0));
    return b.monthlyLimitPaisa;
  }

  int get totalBudgetPaisa => budgets.fold(0, (sum, b) => sum + b.monthlyLimitPaisa);
}

// Dart doesn't allow const DateTime constructor — use a simple default
class _Now implements DateTime {
  const _Now();
  @override dynamic noSuchMethod(Invocation i) => DateTime.now();
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  ExpensesNotifier() : super(ExpensesState(selectedMonth: DateTime.now())) {
    _load();
  }

  void _load() {
    final expenses = HiveService.expenses.values.whereType<ExpenseModel>().toList();
    final budgets = HiveService.budgets.values.whereType<BudgetModel>().toList();
    state = state.copyWith(expenses: expenses, budgets: budgets);
    _applyRecurring();
  }

  void _applyRecurring() {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month}';
    final alreadyApplied = HiveService.settings.get('recurring_applied_$monthKey') ?? false;
    if (alreadyApplied) return;

    for (final e in state.expenses.where((e) => e.isRecurring)) {
      final alreadyThisMonth = state.expenses.any((ex) =>
          ex.note == e.note &&
          ex.category == e.category &&
          ex.date.year == now.year &&
          ex.date.month == now.month &&
          !ex.isRecurring);
      if (!alreadyThisMonth) {
        addExpense(ExpenseModel(
          amountPaisa: e.amountPaisa,
          category: e.category,
          note: '${e.note} (auto)',
          date: DateTime(now.year, now.month, e.date.day),
          isRecurring: false,
        ));
      }
    }
    HiveService.settings.put('recurring_applied_$monthKey', true);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await HiveService.expenses.put(expense.id, expense);
    state = state.copyWith(expenses: [...state.expenses, expense]);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await HiveService.expenses.put(expense.id, expense);
    final updated = [...state.expenses];
    final idx = updated.indexWhere((e) => e.id == expense.id);
    if (idx >= 0) updated[idx] = expense;
    state = state.copyWith(expenses: updated);
  }

  Future<void> deleteExpense(String id) async {
    await HiveService.expenses.delete(id);
    state = state.copyWith(expenses: state.expenses.where((e) => e.id != id).toList());
  }

  Future<void> setBudget(String category, int amountPaisa) async {
    final existing = state.budgets.where((b) => b.category == category).toList();
    final budget = BudgetModel(category: category, monthlyLimitPaisa: amountPaisa);
    await HiveService.budgets.put(category, budget);

    final updated = [...state.budgets.where((b) => b.category != category), budget];
    state = state.copyWith(budgets: updated);
  }

  void setSelectedMonth(DateTime month) => state = state.copyWith(selectedMonth: month);

  void previousMonth() {
    final m = state.selectedMonth;
    state = state.copyWith(selectedMonth: DateTime(m.year, m.month - 1));
  }

  void nextMonth() {
    final m = state.selectedMonth;
    final next = DateTime(m.year, m.month + 1);
    if (next.isAfter(DateTime.now())) return;
    state = state.copyWith(selectedMonth: next);
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, ExpensesState>(
  (ref) => ExpensesNotifier(),
);
