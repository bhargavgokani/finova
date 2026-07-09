import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final bool isLoading;

  const TransactionState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.searchQuery = '',
    this.isLoading = true,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    bool? isLoading,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    searchQuery,
    isLoading,
  ];
}
