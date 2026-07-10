import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_state.dart';

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

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class ApplyFilters extends TransactionEvent {
  final TransactionFilters filters;

  const ApplyFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class ChangeSortOption extends TransactionEvent {
  final TransactionSortOption sortOption;

  const ChangeSortOption(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}
