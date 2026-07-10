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

  // No seeded data - the user creates their own budgets. Must be growable
  // (not `const []`), since addBudget() mutates this list directly.
  static List<BudgetModel> _buildMockBudgets() => [];
}
