import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';

/// Structured filter selection, applied together with search. All fields
/// null/empty means "no filter" for that dimension.
class TransactionFilters extends Equatable {
  final String? category;
  final TransactionType? transactionType;
  final PaymentMethod? paymentMethod;
  final DateTimeRange? dateRange;

  const TransactionFilters({
    this.category,
    this.transactionType,
    this.paymentMethod,
    this.dateRange,
  });

  bool get isActive =>
      category != null ||
      transactionType != null ||
      paymentMethod != null ||
      dateRange != null;

  @override
  List<Object?> get props => [
    category,
    transactionType,
    paymentMethod,
    dateRange,
  ];
}

enum TransactionSortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
}

extension TransactionSortOptionLabel on TransactionSortOption {
  String get label {
    switch (this) {
      case TransactionSortOption.dateNewest:
        return 'Date: Newest First';
      case TransactionSortOption.dateOldest:
        return 'Date: Oldest First';
      case TransactionSortOption.amountHighest:
        return 'Amount: Highest First';
      case TransactionSortOption.amountLowest:
        return 'Amount: Lowest First';
    }
  }
}

class TransactionState extends Equatable {
  static const int pageSize = 20;

  final List<TransactionModel> transactions;
  // Filtered + sorted, but NOT paginated.
  final List<TransactionModel> filteredTransactions;
  // filteredTransactions, sliced down to visibleCount - what the UI renders.
  final List<TransactionModel> visibleTransactions;
  final String searchQuery;
  final TransactionFilters filters;
  final TransactionSortOption sortOption;
  final int visibleCount;
  final bool isLoading;

  const TransactionState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.visibleTransactions = const [],
    this.searchQuery = '',
    this.filters = const TransactionFilters(),
    this.sortOption = TransactionSortOption.dateNewest,
    this.visibleCount = pageSize,
    this.isLoading = true,
  });

  bool get hasMore => visibleTransactions.length < filteredTransactions.length;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    List<TransactionModel>? visibleTransactions,
    String? searchQuery,
    TransactionFilters? filters,
    TransactionSortOption? sortOption,
    int? visibleCount,
    bool? isLoading,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      visibleTransactions: visibleTransactions ?? this.visibleTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortOption: sortOption ?? this.sortOption,
      visibleCount: visibleCount ?? this.visibleCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    visibleTransactions,
    searchQuery,
    filters,
    sortOption,
    visibleCount,
    isLoading,
  ];
}
