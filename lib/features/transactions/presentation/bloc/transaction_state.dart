import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;

  const TransactionState({this.transactions = const [], this.isLoading = true});

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [transactions, isLoading];
}
