enum TransactionType { income, expense }

enum PaymentMethod { cash, card, upi, bankTransfer }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType transactionType;
  final PaymentMethod paymentMethod;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.transactionType,
    required this.paymentMethod,
    this.notes,
  });
}
