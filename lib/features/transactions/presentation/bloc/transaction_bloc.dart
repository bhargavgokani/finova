import 'dart:async';

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
    // Currently both events reload the transaction list.
    // Keeping separate events allows different behavior later.
    on<LoadTransactions>(
      (event, emit) => emit(_loadTransactions(state.searchQuery)),
    );
    on<RefreshTransactions>(
      (event, emit) => emit(_loadTransactions(state.searchQuery)),
    );
    on<SearchTransactions>(_onSearchTransactions);
    on<_SearchDebounced>((event, emit) => emit(_loadTransactions(event.query)));
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) {
    _transactionRepository.addTransaction(event.transaction);
    emit(_loadTransactions(state.searchQuery));
  }

  void _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) {
    _transactionRepository.updateTransaction(event.transaction);
    emit(_loadTransactions(state.searchQuery));
  }

  void _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) {
    _transactionRepository.deleteTransaction(event.id);
    emit(_loadTransactions(state.searchQuery));
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

  TransactionState _loadTransactions(String query) {
    final transactions = _transactionRepository.getTransactions();
    return TransactionState(
      transactions: transactions,
      filteredTransactions: _filterTransactions(transactions, query),
      searchQuery: query,
      isLoading: false,
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return transactions;

    return transactions.where((t) {
      final notes = t.notes?.toLowerCase() ?? '';
      return t.title.toLowerCase().contains(normalizedQuery) ||
          t.category.toLowerCase().contains(normalizedQuery) ||
          notes.contains(normalizedQuery);
    }).toList();
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
