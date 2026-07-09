import '../models/budget_model.dart';

/// In-memory budget data source.
///
/// There is no backend yet - everything lives in a local list. Swap this
/// out for a real data source later without changing the method signatures.
class BudgetRepository {
  final List<BudgetModel> _budgets = _buildMockBudgets();

  List<BudgetModel> getBudgets() => List.unmodifiable(_budgets);

  void addBudget(BudgetModel budget) {
    _budgets.add(budget);
  }

  void updateBudget(BudgetModel budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index == -1) return;
    _budgets[index] = budget;
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
  }

  static List<BudgetModel> _buildMockBudgets() {
    return const [
      BudgetModel(
        id: 'bg1',
        category: 'Food',
        amount: 8000,
        period: BudgetPeriod.monthly,
      ),
      BudgetModel(
        id: 'bg2',
        category: 'Transport',
        amount: 3000,
        period: BudgetPeriod.monthly,
      ),
      BudgetModel(
        id: 'bg3',
        category: 'Shopping',
        amount: 5000,
        period: BudgetPeriod.monthly,
      ),
      BudgetModel(
        id: 'bg4',
        category: 'Bills',
        amount: 4000,
        period: BudgetPeriod.monthly,
      ),
    ];
  }
}
