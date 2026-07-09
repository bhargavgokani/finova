import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository)
    : super(const TransactionState()) {
    // Currently both events reload the transaction list.
    // Keeping separate events allows different behavior later.
    on<LoadTransactions>((event, emit) => emit(_loadTransactions()));
    on<RefreshTransactions>((event, emit) => emit(_loadTransactions()));
  }

  TransactionState _loadTransactions() {
    return TransactionState(
      transactions: _transactionRepository.getTransactions(),
      isLoading: false,
    );
  }
}
