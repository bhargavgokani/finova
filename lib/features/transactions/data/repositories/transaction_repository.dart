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

    final result = <String, double>{};
    for (final t in _transactions) {
      if (t.transactionType != TransactionType.expense) continue;
      if (t.date.isBefore(earliestMonth) || t.date.isAfter(now)) continue;
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

  static List<TransactionModel> _buildMockTransactions() {
    final now = DateTime.now();
    DateTime daysAgo(int days) => now.subtract(Duration(days: days));

    return [
      TransactionModel(
        id: 't1',
        title: 'Salary',
        amount: 55000,
        date: DateTime(now.year, now.month, 1),
        category: 'Salary',
        transactionType: TransactionType.income,
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      TransactionModel(
        id: 't2',
        title: 'Freelancing',
        amount: 15000,
        date: daysAgo(5),
        category: 'Freelance',
        transactionType: TransactionType.income,
        paymentMethod: PaymentMethod.upi,
      ),
      TransactionModel(
        id: 't3',
        title: 'Groceries',
        amount: 3200,
        date: daysAgo(2),
        category: 'Groceries',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.card,
      ),
      TransactionModel(
        id: 't4',
        title: 'Netflix',
        amount: 649,
        date: daysAgo(6),
        category: 'Subscription',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.card,
        notes: 'Monthly plan',
      ),
      TransactionModel(
        id: 't5',
        title: 'Petrol',
        amount: 2000,
        date: daysAgo(3),
        category: 'Transport',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
      ),
      TransactionModel(
        id: 't6',
        title: 'Electricity Bill',
        amount: 1800,
        date: daysAgo(10),
        category: 'Utilities',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      TransactionModel(
        id: 't7',
        title: 'Restaurant',
        amount: 1450,
        date: daysAgo(1),
        category: 'Food & Dining',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.upi,
      ),
      TransactionModel(
        id: 't8',
        title: 'Shopping',
        amount: 4200,
        date: daysAgo(4),
        category: 'Shopping',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.card,
      ),
      TransactionModel(
        id: 't9',
        title: 'Coffee',
        amount: 180,
        date: daysAgo(0),
        category: 'Food & Dining',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
      ),
      TransactionModel(
        id: 't10',
        title: 'Internet Bill',
        amount: 999,
        date: daysAgo(8),
        category: 'Utilities',
        transactionType: TransactionType.expense,
        paymentMethod: PaymentMethod.upi,
      ),
    ];
  }
}
