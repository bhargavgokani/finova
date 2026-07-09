import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}

class SearchTransactions extends TransactionEvent {
  final String query;

  const SearchTransactions(this.query);

  @override
  List<Object?> get props => [query];
}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
