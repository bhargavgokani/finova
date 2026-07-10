import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  Timer? _searchDebounce;

  TransactionBloc(this._transactionRepository)
    : super(const TransactionState()) {
    // Every event below (except LoadMoreTransactions) reruns search +
    // filters + sort and resets pagination to the first page, so those
    // three always stay in sync and survive CRUD operations.
    on<LoadTransactions>((event, emit) => emit(_loadTransactions()));
    on<RefreshTransactions>((event, emit) => emit(_loadTransactions()));
    on<SearchTransactions>(_onSearchTransactions);
    on<_SearchDebounced>(
      (event, emit) => emit(_loadTransactions(searchQuery: event.query)),
    );
    on<ApplyFilters>(
      (event, emit) => emit(_loadTransactions(filters: event.filters)),
    );
    on<ChangeSortOption>(
      (event, emit) => emit(_loadTransactions(sortOption: event.sortOption)),
    );
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) {
    _transactionRepository.addTransaction(event.transaction);
    emit(_loadTransactions());
  }

  void _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) {
    _transactionRepository.updateTransaction(event.transaction);
    emit(_loadTransactions());
  }

  void _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) {
    _transactionRepository.deleteTransaction(event.id);
    emit(_loadTransactions());
  }

  // Typing dispatches SearchTransactions on every keystroke. Instead of
  // filtering immediately, restart a 300ms timer each time - only the
  // last keystroke's timer survives to trigger the actual filtering,
  // via the internal _SearchDebounced event.
  void _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => add(_SearchDebounced(event.query)),
    );
  }

  void _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) {
    final newVisibleCount = state.visibleCount + TransactionState.pageSize;
    emit(
      state.copyWith(
        visibleCount: newVisibleCount,
        visibleTransactions: state.filteredTransactions
            .take(newVisibleCount)
            .toList(),
      ),
    );
  }

  TransactionState _loadTransactions({
    String? searchQuery,
    TransactionFilters? filters,
    TransactionSortOption? sortOption,
  }) {
    final query = searchQuery ?? state.searchQuery;
    final activeFilters = filters ?? state.filters;
    final sort = sortOption ?? state.sortOption;

    final transactions = _transactionRepository.getTransactions();
    final filtered = _sortTransactions(
      _filterTransactions(transactions, query, activeFilters),
      sort,
    );

    return TransactionState(
      transactions: transactions,
      filteredTransactions: filtered,
      visibleTransactions: filtered.take(TransactionState.pageSize).toList(),
      searchQuery: query,
      filters: activeFilters,
      sortOption: sort,
      isLoading: false,
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String query,
    TransactionFilters filters,
  ) {
    final normalizedQuery = query.trim().toLowerCase();

    return transactions.where((t) {
      if (normalizedQuery.isNotEmpty) {
        final notes = t.notes?.toLowerCase() ?? '';
        final matchesSearch =
            t.title.toLowerCase().contains(normalizedQuery) ||
            t.category.toLowerCase().contains(normalizedQuery) ||
            notes.contains(normalizedQuery);
        if (!matchesSearch) return false;
      }

      if (filters.category != null && t.category != filters.category) {
        return false;
      }
      if (filters.transactionType != null &&
          t.transactionType != filters.transactionType) {
        return false;
      }
      if (filters.paymentMethod != null &&
          t.paymentMethod != filters.paymentMethod) {
        return false;
      }
      if (filters.dateRange != null &&
          !_isWithinDateRange(t.date, filters.dateRange!)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _isWithinDateRange(DateTime date, DateTimeRange range) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  List<TransactionModel> _sortTransactions(
    List<TransactionModel> transactions,
    TransactionSortOption sortOption,
  ) {
    final sorted = List<TransactionModel>.from(transactions);
    switch (sortOption) {
      case TransactionSortOption.dateNewest:
        sorted.sort((a, b) => b.date.compareTo(a.date));
      case TransactionSortOption.dateOldest:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case TransactionSortOption.amountHighest:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
      case TransactionSortOption.amountLowest:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return sorted;
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

/// Internal event fired once the search debounce timer elapses.
/// Not dispatched by the UI - only [SearchTransactions] is public.
class _SearchDebounced extends TransactionEvent {
  final String query;

  const _SearchDebounced(this.query);

  @override
  List<Object?> get props => [query];
}
