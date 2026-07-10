import '../models/transaction_model.dart';

/// One month's income and expense totals, returned by
/// [TransactionRepository.calculateIncomeVsExpense].
class MonthlyTotal {
  final DateTime month;
  final double income;
  final double expense;

  const MonthlyTotal({
    required this.month,
    required this.income,
    required this.expense,
  });
}

/// In-memory transaction data source, shared by Dashboard, Transactions,
/// Budget and Analytics.
///
/// There is no backend yet - everything lives in a local list. Swap this
/// out for a real data source later without changing the method signatures.
class TransactionRepository {
  final List<TransactionModel> _transactions = _buildMockTransactions();

  List<TransactionModel> getTransactions() => List.unmodifiable(_transactions);

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
  }

  void updateTransaction(TransactionModel transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;
    _transactions[index] = transaction;
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
  }

  List<TransactionModel> getRecentTransactions(int limit) {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  double calculateTotalBalance() {
    return _transactions.fold(0.0, (balance, t) {
      return t.transactionType == TransactionType.income
          ? balance + t.amount
          : balance - t.amount;
    });
  }

  double calculateMonthlyIncome() => _monthlyTotal(TransactionType.income);

  double calculateMonthlyExpense() => _monthlyTotal(TransactionType.expense);

  double calculateSpentForCategory(String category) {
    return _monthlyTotal(TransactionType.expense, category: category);
  }

  // Buckets this month's expenses into 4 weeks by day-of-month, so the last
  // few days of longer months just fold into week 4 instead of a week 5.
  List<double> calculateWeeklySpending() {
    final now = DateTime.now();
    final weeklyTotals = List<double>.filled(4, 0);

    for (final t in _transactions) {
      if (t.transactionType != TransactionType.expense) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;

      final weekIndex = ((t.date.day - 1) ~/ 7).clamp(0, 3);
      weeklyTotals[weekIndex] += t.amount;
    }

    return weeklyTotals;
  }

  double _monthlyTotal(
    TransactionType type, {
    String? category,
    DateTime? month,
  }) {
    final target = month ?? DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.transactionType == type &&
              (category == null || t.category == category) &&
              t.date.year == target.year &&
              t.date.month == target.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Expense total per category, over the last [monthsBack] months
  // (including the current one).
  Map<String, double> calculateExpenseByCategory({required int monthsBack}) {
    final now = DateTime.now();
    final earliestMonth = DateTime(now.year, now.month - (monthsBack - 1));
    return _expenseByCategory(
      (date) => !date.isBefore(earliestMonth) && !date.isAfter(now),
    );
  }

  // Expense total per category for a single calendar month.
  Map<String, double> calculateExpenseByCategoryForMonth(DateTime month) {
    return _expenseByCategory(
      (date) => date.year == month.year && date.month == month.month,
    );
  }

  Map<String, double> _expenseByCategory(bool Function(DateTime date) inRange) {
    final result = <String, double>{};
    for (final t in _transactions) {
      if (t.transactionType != TransactionType.expense) continue;
      if (!inRange(t.date)) continue;
      result.update(
        t.category,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    return result;
  }

  // One entry per month for the last [monthsBack] months (including the
  // current one), oldest first.
  List<MonthlyTotal> calculateIncomeVsExpense({required int monthsBack}) {
    final now = DateTime.now();
    return List.generate(monthsBack, (index) {
      final month = DateTime(now.year, now.month - (monthsBack - 1 - index));
      return MonthlyTotal(
        month: month,
        income: _monthlyTotal(TransactionType.income, month: month),
        expense: _monthlyTotal(TransactionType.expense, month: month),
      );
    });
  }

  // No seeded data - the user builds their own transaction history.
  static List<TransactionModel> _buildMockTransactions() => [];
}
