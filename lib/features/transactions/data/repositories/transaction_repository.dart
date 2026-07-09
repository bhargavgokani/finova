import '../models/transaction_model.dart';

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

  double _monthlyTotal(TransactionType type) {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.transactionType == type &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
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
