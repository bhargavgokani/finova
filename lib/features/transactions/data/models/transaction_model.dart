/// Predefined transaction categories, shared by TransactionForm's
/// category dropdown and ReceiptScannerPage's simulated OCR result.
const List<String> predefinedCategories = [
  'Salary',
  'Freelancing',
  'Food',
  'Shopping',
  'Bills',
  'Transport',
  'Entertainment',
  'Healthcare',
  'Other',
];

enum TransactionType { income, expense }

extension TransactionTypeLabel on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}

enum PaymentMethod { cash, card, upi, bankTransfer }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType transactionType;
  final PaymentMethod paymentMethod;
  final String? notes;
  final String? receiptImagePath;
  final List<String> tags;
  final bool isRecurring;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.transactionType,
    required this.paymentMethod,
    this.notes,
    this.receiptImagePath,
    this.tags = const [],
    this.isRecurring = false,
  });
}
